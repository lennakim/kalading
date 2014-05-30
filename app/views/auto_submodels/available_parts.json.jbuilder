json.array! @parts do |p|
  json.id p.id
  json.brand p.part_brand.name
  json.number p.number
  if p.price <= 0.0 && p.url_price > 0
    price = humanized_money_with_symbol p.url_price
    price += I18n.t(:url_price)
  else
    price = humanized_money_with_symbol p.price
  end
  json.price price
  json.store do
    json.array! p.partbatches.group_by(&:storehouse) do |sh, pbs|
      json.storehouse sh.name
      json.quantity pbs.sum(&:remained_quantity)
    end
  end
end