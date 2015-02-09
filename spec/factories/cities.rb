#encoding: UTF-8
FactoryGirl.define do
  factory :beijing, class: City do
    name '北京市'
    order_capacity 99
    area_code '010'
    opened true
    initialize_with { City.find_or_create_by(name: name)}
  end
end