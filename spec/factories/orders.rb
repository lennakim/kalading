#encoding: UTF-8
FactoryGirl.define do
  trait :maintain_order_traits do
    client_id '0a0b7D0C1MNP'
    pay_type 1
    reciept_type 1
    reciept_title "卡拉丁汽车技术"
    client_comment "请按时到场"
    association :city, factory: :beijing
    association :engineer, factory: :user
    before(:create) do |o|
      o.service_types << create(:auto_maintain)
    end
  end
  
  factory :unscheduled_order, class: Order, traits: [:maintain_order_traits] do
    address '订单地址'
    name 'Sheldon'
    phone_num "13888888888"
    car_location "京"
    car_num "N333M3"
    auto_km '20000'
    vin 'VIN of auto'
    serve_datetime "2014-05-18 12:00"
    state 3
  end

  factory :scheduled_order, class: Order, traits: [:maintain_order_traits] do
    address 'Some address'
    name 'Name of client'
    phone_num "13888888888"
    client_id '0a0b7D0C1MNP'
    car_location "京"
    car_num "N000M3"
    auto_km '100'
    vin 'VIN of auto'
    serve_datetime "2014-05-16 15:44"
    state 4
  end

  factory :serve_done_order, class: Order, traits: [:maintain_order_traits] do
    address 'Some address'
    name 'Name of client'
    phone_num "13888888888"
    client_id '0a0b7D0C1MNP'
    car_location "京"
    car_num "MM0588"
    auto_km '2000'
    vin 'VIN of auto'
    serve_datetime "2014-05-13 19:44"
    state 5
  end

  factory :revisited_order, class: Order, traits: [:maintain_order_traits] do
    address 'Some address'
    name 'Name of client'
    phone_num "13666666666"
    client_id '0a0b7D0C1MNP'
    car_location "京"
    car_num "MM0588"
    auto_km '2000'
    vin 'VIN of auto'
    serve_datetime "2014-04-13 19:44"
    state 7
  end
end