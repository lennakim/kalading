json.array! @orders do |o|
  json.name o.name[0]
  json.car_num o.car_location + o.car_num
  if o.auto_submodel
    json.auto_model o.auto_submodel.full_name
  elsif o.service_types.exists?
    json.auto_model o.service_types.first.name
  end
end
