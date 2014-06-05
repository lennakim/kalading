json.array! @maintains do |m|
  json.date m.created_at.strftime('%Y-%m-%d')
  json.parts do
    o = Order.find(m.order_id)
    json.array! o.parts do |part|
      json.type part.part_type.name
      json.brand part.part_brand.name
      json.number part.number
    end
  end
end  