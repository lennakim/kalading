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
  a = parts.collect do |p|
      if p.part_type.name == I18n.t(:engine_oil)
        { brand: p.part_brand.name, number: p.spec}
      else
        { brand: p.part_brand.name, number: p.id }
      end
  end
  a.uniq
end

json.parts @order.parts.group_by {|x| x.part_type.name} do |v|
  json.set! v[0] do
    json.array! parts_to_user_friendly.call(v[1])
  end
end

json.applicable_parts @order.auto_submodel.parts_includes_motoroil.group_by {|x| x.part_type.name} do |v|
  json.set! v[0] do
    json.array! parts_to_user_friendly.call(v[1])
  end
end


