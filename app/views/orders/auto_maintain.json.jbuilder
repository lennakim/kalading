json.price @order.calc_price.to_f
json.price_without_discount @order.price_without_discount.to_f
json.service_price @order.service_types.first.price.to_f if @order.service_types.exists?
json.discount do
  if @order.discounts.exists?
    json.name @order.discounts.first.name
    json.expire_date @order.discounts.first.expire_date
  end
  if @discount_error
    json.error @discount_error
  end
end

img = ["car_blue.png", "car_red.png"][@order.auto_submodel.motoroil_cap % 2]
json.pic_url "#{request.protocol}intranet.kalading.com#{asset_path(img)}"
json.name @order.auto_submodel.auto_model.auto_brand.name + ' ' + @order.auto_submodel.auto_model.name + ' ' + I18n.t(:auto_maintain)

parts_to_user_friendly = Proc.new do |parts|
  # engine oil with same spec and brand are merged
  b = {}
  if params[:city_id]
    storehouses = City.find(params[:city_id]).storehouses
  else
    storehouses = Storehouse.all
  end
  a = parts.each do |p|
      if p.part_type.name == I18n.t(:engine_oil)
        b[{brand: p.part_brand.name, number: p.spec}] ||= { brand: p.part_brand.name, number: p.spec, price: 0, quantity: 0, total_quantity: 0}
        b[{brand: p.part_brand.name, number: p.spec}][:price] += p.ref_price.to_f * @order.auto_submodel.cals_part_count(p)
        b[{brand: p.part_brand.name, number: p.spec}][:quantity] += p.partbatches.any_in(storehouse_id: storehouses.map(&:id)).sum(&:remained_quantity)
        b[{brand: p.part_brand.name, number: p.spec}][:total_quantity] += p.partbatches.sum(&:remained_quantity)
      elsif p.part_type.name == I18n.t(:cabin_filter)
        if params[:pm25].blank? || p.part_brand_id.to_s == '539d4d019a94e4de84000567'
          b[{brand: p.part_brand.name, number: p.id, spec: p.spec}] = { brand: p.part_brand.name, number: p.id, spec: p.spec, price: p.ref_price.to_f * @order.auto_submodel.cals_part_count(p), quantity: p.partbatches.any_in(storehouse_id: storehouses.map(&:id)).sum(&:remained_quantity) }
          b[{brand: p.part_brand.name, number: p.id, spec: p.spec}][:total_quantity] = p.partbatches.sum(&:remained_quantity)
          b[{brand: p.part_brand.name, number: p.id, spec: p.spec}][:xxx] = p.part_brand_id
        end
      else
        b[{brand: p.part_brand.name, number: p.id, spec: p.spec}] = { brand: p.part_brand.name, number: p.id, price: p.ref_price.to_f * @order.auto_submodel.cals_part_count(p), quantity: p.partbatches.any_in(storehouse_id: storehouses.map(&:id)).sum(&:remained_quantity) }
        b[{brand: p.part_brand.name, number: p.id, spec: p.spec}][:total_quantity] = p.partbatches.sum(&:remained_quantity)
      end
  end
  b.values
end

json.parts @order.parts.group_by {|x| x.part_type.name} do |v|
  json.set! v[0] do
    json.array! parts_to_user_friendly.call(v[1])
  end
end

json.applicable_parts @order.auto_submodel.parts_includes_motoroil_ignore_quantity.group_by {|x| x.part_type.name} do |v|
  json.set! v[0] do
    json.array! parts_to_user_friendly.call(v[1])
  end
end


