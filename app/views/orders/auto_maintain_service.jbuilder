json.(@order, :auto_submodel_id)
json.price @order.calc_price.to_f
json.parts @order.parts.group_by {|x| x.part_type.name}
json.applicable_parts Hash[@order.auto_submodel.parts_by_type.map{ |k, v| [ k.name, v ] }]

