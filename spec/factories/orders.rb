#encoding: UTF-8
FactoryGirl.define do
  factory :unscheduled_order, class: Order do
    address '订单地址'
    name 'Sheldon'
    phone_num "13888888888"
    client_id '0a0b7D0C1MNP'
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
    client_id '0a0b7D0C1MNP'
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
    client_id '0a0b7D0C1MNP'
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

  factory :revisited_order, class: Order do
    address 'Some address'
    name 'Name of client'
    phone_num "13666666666"
    client_id '0a0b7D0C1MNP'
    car_location "京"
    car_num "MM0588"
    auto_km '2000'
    vin 'VIN of auto'
    serve_datetime "2014-04-13 19:44"
    pay_type 1
    reciept_type 1
    reciept_title "卡拉丁汽车技术"
    client_comment "请按时到场"
    state 7
    city_id City.find_by(name: '北京市').id
    service_type_ids [ServiceType.first.id]
  end

  factory :auto_maintain_1, class: Maintain do
    order_id Order.first.id
    outlook_desc '良好'
    buy_date '2008-10-01'
    VIN "040471abcd"
    insurance_date '2008-10-01'
    auto_color "蓝色"
    engine_num "LFV3223233"
    oil_position 0
    oil_out 5
    oil_in 6
    oil_desc 0
    oil_sample_collected true
    oil_sample_number 0
    oil_filter_changed true
    oil_filter_not_changed_reason ''
    air_filter_desc 1
    air_filter_changed true
    air_filter_not_changed_reason ''
    cabin_filter_desc 0
    cabin_filter_changed false
    cabin_filter_not_changed_reason '不脏不用换'
  
    brake_oil_desc 0
    brake_oil_boiling_point 0
    brake_oil_position 0
    antifreeze_desc 0
    antifreeze_freezing_point 0
    antifreeze_position 0
    antifreeze_color ""
    steering_oil_desc 0
    steering_oil_position 0
    gearbox_oil_desc 0
    gearbox_oil_position 0
    glass_water_desc 0
    glass_water_add false
    glass_water_amount 0
    battery_desc 0
    battery_charge ""
    battery_health ""
    battery_light_color ""
    battery_head_desc 0
    engine_hose_and_line_desc 0
  
    front_wiper_desc 0
    back_wiper_desc 0
    extinguisher_desc 0
    warning_board_desc 0
    spare_tire_desc 0
  
    km_be_zero false
    curr_km "35000"
    next_maintain_km "40000"
    comment "干得好"
    total_time 3600

    lights_attributes [
      {
        name: '前灯',
        desc: '左不亮'
      },
      {
        name: '后灯',
        desc: '左不亮'
      }
    ]

    wheels_attributes [
      {
        name: '左前胎',
        brand: "米其林",
        factory_data_checked: true,
        factory_data: '2008-10-10',
        tread_depth: 1.5,
        ageing_desc: 0,
        tread_desc: [0],
        sidewall_desc: [0],
        pressure: 2.0,
        width: 0,
        brake_pad_checked: true,
        brake_pad_thickness: 0,
        brake_disc_desc: [0]
      },
      {
        name: '右前胎',
        brand: "米其林",
        factory_data_checked: true,
        factory_data: '2008-10-10',
        tread_depth: 1.5,
        ageing_desc: 0,
        tread_desc: [0],
        sidewall_desc: [0],
        pressure: 2.0,
        width: 0,
        brake_pad_checked: true,
        brake_pad_thickness: 0,
        brake_disc_desc: [0]
      }
    ]
  end

  factory :auto_maintain_2, class: Maintain do
    order_id Order.first.id
    outlook_desc '残花败柳'
    buy_date '2008-10-01'
    VIN "040471abcd"
    insurance_date '2008-10-01'
    auto_color "红色"
    engine_num "LFV3223233"
    oil_position 0
    oil_out 5
    oil_in 6
    oil_desc 0
    oil_sample_collected true
    oil_sample_number 0
    oil_filter_changed true
    oil_filter_not_changed_reason ''
    air_filter_desc 1
    air_filter_changed true
    air_filter_not_changed_reason ''
    cabin_filter_desc 0
    cabin_filter_changed true
    cabin_filter_not_changed_reason ''
  
    brake_oil_desc 0
    brake_oil_boiling_point 0
    brake_oil_position 0
    antifreeze_desc 0
    antifreeze_freezing_point 0
    antifreeze_position 0
    antifreeze_color ""
    steering_oil_desc 0
    steering_oil_position 0
    gearbox_oil_desc 0
    gearbox_oil_position 0
    glass_water_desc 0
    glass_water_add false
    glass_water_amount 0
    battery_desc 0
    battery_charge ""
    battery_health ""
    battery_light_color ""
    battery_head_desc 0
    engine_hose_and_line_desc 0
  
    front_wiper_desc 0
    back_wiper_desc 0
    extinguisher_desc 0
    warning_board_desc 0
    spare_tire_desc 0
  
    km_be_zero false
    curr_km "25555"
    next_maintain_km "30555"
    comment "干得好"
    total_time 1800
    
    lights_attributes [
      {
        name: '前灯',
        desc: [0]
      },
      {
        name: '后灯',
        desc: [2, 3]
      }
    ]

    wheels_attributes [
      {
        name: '左前胎',
        brand: "米其林",
        factory_data_checked: true,
        factory_data: '2008-10-10',
        tread_depth: 1.5,
        ageing_desc: 0,
        tread_desc: [0],
        sidewall_desc: [0],
        pressure: 2.0,
        width: 0,
        brake_pad_checked: true,
        brake_pad_thickness: 0,
        brake_disc_desc: [0]
      },
      {
        name: '右前胎',
        brand: "米其林",
        factory_data_checked: true,
        factory_data: '2008-10-10',
        tread_depth: 1.5,
        ageing_desc: 0,
        tread_desc: [0],
        sidewall_desc: [0],
        pressure: 2.0,
        width: 0,
        brake_pad_checked: true,
        brake_pad_thickness: 0,
        brake_disc_desc: [0]
      }
    ]
  end

end