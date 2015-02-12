#encoding: UTF-8
FactoryGirl.define do
  factory :maintain, class: Maintain do
    outlook_desc "崭新"
    buy_date Date.parse('2014-01-1')
    VIN "12345678901abcdefg"
    insurance_date ""
    auto_color ""
    engine_num ""
  
    oil_position 1
    oil_out 0
    oil_in 0
    oil_desc 0
    oil_sample_collected false
    oil_sample_number 0
    oil_filter_changed false
    oil_filter_not_changed_reason ""
  
    air_filter_desc 0
    air_filter_changed false
    air_filter_not_changed_reason ""
  
    cabin_filter_desc 0
    cabin_filter_changed false
    cabin_filter_not_changed_reason ""
  
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
    last_km ""
    curr_km ""
    next_maintain_km ""
    comment ""
    total_time 0
    association :order, factory: :revisited_order
  end
end