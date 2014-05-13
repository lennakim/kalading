#encoding: UTF-8
FactoryGirl.define do
  factory :unscheduled_order, class: Order do
    address '订单地址'
    name 'Sheldon'
    phone_num "13888888888"
    car_location "京"
    car_num "N333M3"
    auto_km '20000'
    vin 'VIN of auto'
    serve_datetime "2014-05-18 12:00"
    pay_type 1
    reciept_type 1
    reciept_title "卡拉丁汽车技术"
    client_comment "请按时到场"
    state 3
    city_id City.find_by(name: '北京市').id
    service_type_ids [ServiceType.first.id, ServiceType.all[1].id]
  end

  factory :scheduled_order, class: Order do
    address 'Some address'
    name 'Name of client'
    phone_num "13888888888"
    car_location "京"
    car_num "N000M3"
    auto_km '100'
    vin 'VIN of auto'
    serve_datetime "2014-05-16 15:44"
    pay_type 1
    reciept_type 1
    reciept_title "卡拉丁汽车技术"
    client_comment "请按时到场"
    state 4
    city_id City.find_by(name: '北京市').id
    service_type_ids [ServiceType.first.id]
  end

  factory :serve_done_order, class: Order do
    address 'Some address'
    name 'Name of client'
    phone_num "13888888888"
    car_location "京"
    car_num "MM0588"
    auto_km '2000'
    vin 'VIN of auto'
    serve_datetime "2014-05-13 19:44"
    pay_type 1
    reciept_type 1
    reciept_title "卡拉丁汽车技术"
    client_comment "请按时到场"
    state 5
    city_id City.find_by(name: '北京市').id
    service_type_ids [ServiceType.first.id]
  end

end