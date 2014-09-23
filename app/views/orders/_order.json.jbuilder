json.id o.id
json.seq o.seq
json.name o.name
json.address o.address
json.phone_num o.phone_num
json.auto_km o.auto_km
json.vin o.vin
json.car_num o.car_location + o.car_num
json.client_comment o.client_comment
json.state t(Order::STATE_STRINGS[o.state])
json.serve_datetime o.serve_datetime.strftime('%Y-%m-%d %H:%M')
json.serve_end_datetime o.serve_end_datetime.strftime('%Y-%m-%d %H:%M') if o.serve_end_datetime
if o.auto_submodel
  json.auto_model o.auto_submodel.full_name
else
  json.auto_model ''
end
json.service_types do
  json.array! o.service_types do |st|
    json.name st.name
  end
end
json.parts do
  json.array! o.parts do |part|
    json.brand part.part_brand.name
    json.type part.part_type.name
    json.number part.number
    json.price part.ref_price.to_f
  end
end
json.price o.calc_price.to_f
json.pay_type t(Order::PAY_TYPE_STRINGS[o.pay_type])
json.cancel_reason o.cancel_reason
json.part_deliver_state o.part_deliver_state
if o.reciept_type == 0
  json.reciept_need false
else
  json.reciept_need true
  json.reciept_title o.reciept_title
  json.reciept_address o.reciept_address
end
json.evaluation o.evaluation_time ? 1 : 0