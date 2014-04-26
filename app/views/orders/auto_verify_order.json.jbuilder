json.price @order.calc_price.to_f
json.price_without_discount @order.price_without_discount.to_f
json.discount do
  if @order.discounts.exists?
    json.name @order.discounts.first.name
    json.expire_date @order.discounts.first.expire_date
  end
  if @discount_error
    json.error @discount_error
  end
end

#json.pic_url 'http://115.28.132.220/images/'
json.name @order.service_types.first.name