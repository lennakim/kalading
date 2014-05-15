json.price @order.calc_price.to_f
json.name @order.auto_submodel.auto_model.auto_brand.name + ' ' + @order.auto_submodel.auto_model.name + ' ' + I18n.t(:auto_maintain)

parts_to_user_friendly = Proc.new do |parts|
  # engine oil with same spec and brand are merged
  b = {}
  a = parts.each do |p|
      if p.part_type.name == I18n.t(:engine_oil)
        b[{brand: p.part_brand.name, number: p.spec}] ||= { brand: p.part_brand.name, number: p.spec, price: 0}
        b[{brand: p.part_brand.name, number: p.spec}][:price] += p.ref_price.to_f * @order.auto_submodel.cals_part_count(p)
      elsif p.part_type.name == I18n.t(:cabin_filter)
        b[{brand: p.part_brand.name, number: p.id, spec: p.spec}] = { brand: p.part_brand.name, price: p.ref_price.to_f * @order.auto_submodel.cals_part_count(p) }
      else
        b[{brand: p.part_brand.name, number: p.id, spec: p.spec}] = { brand: p.part_brand.name, price: p.ref_price.to_f * @order.auto_submodel.cals_part_count(p) }
      end
  end
  b.values
end

json.parts @order.parts.group_by {|x| x.part_type.name} do |v|
  json.set! v[0] do
    json.array! parts_to_user_friendly.call(v[1])
  end
end



