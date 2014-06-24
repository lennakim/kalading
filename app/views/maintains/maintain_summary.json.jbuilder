o = Order.find(@m.order_id)
json.car_num o.car_location + o.car_num
json.serve_datetime o.serve_datetime.strftime('%Y-%m-%d %H:%M')
json.curr_km @m.curr_km
json.next_maintain_km @m.next_maintain_km
json.lights do
  json.array! @m.lights do |light|
    json.name light.name
    json.desc light.desc
  end  
end
json.wheels do
  json.array! @m.wheels do |w|
    json.name w.name
    json.pressure w.pressure
    if w.name != 'spare' 
      json.factory_data w.factory_data
      json.tread_depth w.tread_depth
      json.ageing_desc w.ageing_desc
      json.tread_desc w.tread_desc
      json.sidewall_desc w.sidewall_desc
      json.brake_pad_checked w.brake_pad_checked
      json.brake_pad_thickness w.brake_pad_thickness
      json.brake_disc_desc w.brake_disc_desc
    end
  end
end
json.spare_tire_desc @m.spare_tire_desc
json.extinguisher_desc @m.extinguisher_desc
json.warning_board_desc @m.warning_board_desc
json.oil_position @m.oil_position
json.oil_desc @m.oil_desc
json.brake_oil_desc @m.brake_oil_desc
json.brake_oil_position @m.brake_oil_position
json.antifreeze_desc @m.antifreeze_desc
json.antifreeze_freezing_point @m.antifreeze_freezing_point
json.antifreeze_position @m.antifreeze_position
json.steering_oil_desc @m.steering_oil_desc
json.gearbox_oil_desc @m.gearbox_oil_desc
json.battery_charge @m.battery_charge
json.battery_health @m.battery_health
json.battery_head_desc @m.battery_head_desc
json.battery_desc @m.battery_desc
json.front_wiper_desc @m.front_wiper_desc
json.back_wiper_desc @m.back_wiper_desc