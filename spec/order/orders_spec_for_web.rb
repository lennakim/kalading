#encoding: UTF-8
require 'spec_helper'

describe '查询城市的服务能力.返回每天可下单数量。start_date为起始日期，end_date为终止日期。', :need_user => true, :need_login => true, :need_maintain_order => true do
  it "查询2014-05-13到2014-06-01的服务能力" do
    response_json = get_json "http://localhost:3000/city_capacity/#{City.find_by(name: '北京市').id}.json?start_date=2014-05-13&end_date=2014-06-12"
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
    expect(h.size).to be > 0
  end
end

describe '查询车型保养套餐', :need_user => true do
  it "查询丰田(一汽) 兰德酷路泽 4.7L 2007.12-2012.02保养套餐" do
    response_json = get_json "http://localhost:3000/auto_maintain_order/531f1ed0098e71b3f80001fb.json"
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
    #expect(h['result']).to eq('succeeded')
    #expect(h['seq']).to be
  end
end

describe '查询车辆品牌', :need_user => true do
  it "查询长城" do
    response_json = get_json "http://localhost:3000/auto_brands/531f1fdb098e71b3f8003522.json"
    expect(response_json.code).to be(200)
    #expect(h['result']).to eq('succeeded')
    #expect(h['seq']).to be
  end
end

describe '新建保养订单。city_id为城市的ID，client_id为用户标识（openid）。', :need_user => true do
  it "新建保养订单" do
    o = {
      parts: [
              {
                brand: "嘉实多",
                number: "极护 SN 0W-40"
              },
              {
                brand: "汉格斯特 Hengst",
                number: "5280cb8e098e71d85e0000d0"
              },
              {
                brand: "曼牌 Mann",
                number: "5246c7e5098e7109280001cd"
              },
              {
                brand: "卡拉丁",
                number: "53672bab9a94e45d440005ae"
              }
      ],
      info: {
              address: "北京朝阳区光华路888号",
              name: "王一迅",
              phone_num: "13888888888",
              client_id: "040471abcd",
              car_location: "京",
              car_num: "N333M3",
              serve_datetime: "2014-06-09 15:44",
              pay_type: 1,
              reciept_type: 1,
              reciept_title: "卡拉丁汽车技术",
              client_comment: "请按时到场",
              city_id: City.find_by(name: '北京市').id.to_s
      }
    }
    response_json = post_json "http://localhost:3000/auto_maintain_order/531f1ed0098e71b3f80001fb.json", o
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
    expect(h['result']).to eq('succeeded')
    expect(h['seq']).to be
    o = Order.find_by(seq: h['seq'])
    expect(o.dispatcher).to be
    puts o.dispatcher.name
    o.destroy
  end
end

describe '查询换空调滤+PM2.5滤芯价格，client_id为用户标识（openid）。', :need_user => true do
  it "查询换空调滤+PM2.5滤芯价格" do
    o = {
      parts: [
              {
                brand: "曼牌 Mann",
                number: "528af433098e7180590042ca"
              },
              {
                brand: "卡拉丁",
                number: "53672bab9a94e45d440005ae"
              }
      ],
      info: {
              address: "北京朝阳区光华路888号",
              name: "王一迅",
              phone_num: "13888888888",
              client_id: "040471abcd",
              car_location: "京",
              car_num: "N333M3",
              serve_datetime: "2014-06-09 15:44",
              pay_type: 1,
              reciept_type: 1,
              reciept_title: "卡拉丁汽车技术",
              client_comment: "请按时到场",
              city_id: City.find_by(name: '北京市').id.to_s
      }
    }
    response_json = post_json "http://localhost:3000/auto_maintain_price/531f1ed0098e71b3f80001fb.json", o
    expect(response_json.code).to be(200)
  end
end

describe '新建换空调滤+PM2.5滤芯订单，client_id为用户标识（openid）。', :need_user => true do
  it "新建保养订单" do
    o = {
      parts: [
              {
                brand: "曼牌 Mann",
                number: "528af433098e7180590042ca"
              },
              {
                brand: "卡拉丁",
                number: "53672bab9a94e45d440005ae"
              }
      ],
      info: {
              address: "北京朝阳区光华路888号",
              name: "王一迅",
              phone_num: "13888888888",
              client_id: "040471abcd",
              car_location: "京",
              car_num: "N333M3",
              serve_datetime: "2014-06-09 15:44",
              pay_type: 1,
              reciept_type: 1,
              reciept_title: "卡拉丁汽车技术",
              client_comment: "请按时到场",
              city_id: City.find_by(name: '北京市').id.to_s
      }
    }
    response_json = post_json "http://localhost:3000/auto_maintain_order/531f1ed0098e71b3f80001fb.json", o
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
    expect(h['result']).to eq('succeeded')
    expect(h['seq']).to be
    o = Order.find_by(seq: h['seq'])
    expect(o.calc_price.to_f).to be(50.0)
    o.destroy
  end
end

describe '新建PM2.5滤芯订单，client_id随便写。', :need_user => true do
  it "新建保养订单" do
    o = {
      parts: [
              {
                brand: "卡拉丁",
                number: "53672bab9a94e45d440005ae"
              }
      ],
      info: {
              address: "北京朝阳区光华路888号",
              name: "王一迅",
              phone_num: "13888888888",
              client_id: "040471abcd",
              car_location: "京",
              car_num: "N333M3",
              serve_datetime: "2014-06-09 15:44",
              pay_type: 1,
              reciept_type: 1,
              reciept_title: "卡拉丁汽车技术",
              client_comment: "请按时到场",
              city_id: City.find_by(name: '北京市').id.to_s
      }
    }
    response_json = post_json "http://localhost:3000/auto_maintain_order/531f1ed0098e71b3f80001fb.json", o
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
    expect(h['result']).to eq('succeeded')
    expect(h['seq']).to be
    o = Order.find_by(seq: h['seq'])
    expect(o.calc_price.to_f).to be(150.0)
    o.destroy
  end
end

describe '新建换空调滤+PM2.5滤芯订单，用户来源为小熊(53eb2a0e9a94e4e940000907)。', :need_user => true do
  it "新建保养订单" do
    o = {
      parts: [
              {
                brand: "曼牌 Mann",
                number: "528af433098e7180590042ca"
              },
              {
                brand: "卡拉丁",
                number: "53672bab9a94e45d440005ae"
              }
      ],
      info: {
              address: "北京朝阳区光华路888号",
              name: "王一迅",
              phone_num: "13888888888",
              client_id: "040471abcd",
              car_location: "京",
              car_num: "N333M3",
              serve_datetime: "2014-06-09 15:44",
              pay_type: 1,
              reciept_type: 1,
              reciept_title: "卡拉丁汽车技术",
              client_comment: "请按时到场",
              city_id: City.find_by(name: '北京市').id.to_s,
              user_type_id: '53eb2a0e9a94e4e940000907'
      }
    }
    response_json = post_json "http://localhost:3000/auto_maintain_order/531f1ed0098e71b3f80001fb.json", o
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
    expect(h['result']).to eq('succeeded')
    expect(h['seq']).to be
    o = Order.find_by(seq: h['seq'])
    expect(o.user_type_id.to_s).to eq('53eb2a0e9a94e4e940000907')
    o.destroy
  end
end

describe '查询多个手机号的订单列表，phone_nums为手机号列表。支持分页，page为页数（从1开始），per为每页返回的订单个数。返回空表示到达最后一页。', :need_user => true, :need_maintain_order => true do
  it "列举第1页订单，每页6个" do
    response_json = get_json "http://localhost:3000/orders.json?phone_nums[]=13888888888&phone_nums[]=13666666666&page=1&per=6"
    # 确认调用成功
    expect(response_json.code).to be(200)
    orders = JSON.parse(response_json)
    # 确认返回值正确
    expect(orders.size).to be > 0
  end

  it "列举第100页订单，到达最后一页" do
    response_json = get_json "http://localhost:3000/orders.json?phone_nums[]=13888888888&phone_nums[]=13666666666&page=100&per=6"
    expect(response_json.code).to be(200)
    orders = JSON.parse(response_json)
    expect(orders.size).to be(0)
  end
end

#describe '查询多个手机号的保养记录列表，phone_nums为手机号列表。支持分页，page为页数（从1开始），per为每页返回的订单个数。返回空表示到达最后一页。返回值：car_num: 车牌号，serve_datetime: 服务时间, curr_km: 当前里程, next_maintain_km: 下次保养里程, lights: 灯光信息，可以为[], lights[i].name: 灯光名称, lights[i].desc: 灯光诊断(0: 良好，1：未检查，2: 左边不亮, 3:右边不亮, 4: 左前不亮, 5: 右前不亮, 6: 左后不亮，7： 右后不亮,8: 高位刹车灯不亮, 9: 雾灯不亮,  wheels: 轮胎信息，可以为[], wheels[i].name: 轮胎名称, wheels[i].pressure: 胎压, wheels[i].factory_data_checked: 是否检查了出厂日期, wheels[i].factory_data: 出厂日期, wheels[i].tread_depth: 花纹深度, wheels[i].ageing_desc: 老化程度, wheels[i].tread_desc: 胎面诊断, wheels[i].sidewall_desc: 胎侧诊断, wheels[i].brake_pad_checked: 刹车片是否检测过, wheels[i].brake_pad_thickness: 刹车片厚度, wheels[i].brake_disc_desc: 刹车片诊断, spare_tire_desc: 备胎信息, extinguisher_desc: 灭火器信息, warning_board_desc: 警示牌, oil_position: 机油位置（0: 高位，1：中位，2：低位，3：未检查), oil_desc: 机油状态（0：清澈，1：脏）, brake_oil_desc: 刹车油状态（0：清澈，1：脏）, brake_oil_position: 刹车油位置（0: 高位，1：中位，2：低位，3：未检查）, antifreeze_desc: 防冻液诊断（0: 清澈，1：浑浊，2：脏，3：未检查）, antifreeze_freezing_point: 防冻液冰点, antifreeze_position: 防冻液位置（0: 高位，1：中位，2：低位，3：未检查）, steering_oil_desc: 转向油诊断（0: 清澈，1：浑浊，2：脏，3：未检查）, gearbox_oil_desc: 变速箱油诊断（0: 清澈，1：浑浊，2：脏，3：未检查）, battery_charge: 电瓶充电量, battery_health: 电瓶健康指数, battery_head_desc: 电瓶桩头诊断(0: 良好，1：腐蚀，2：未检查), battery_desc: 电瓶诊断(0: 良好，1：破损，2：泄露，3：未检查), engine_hose_and_line_desc: 车内软管和线路诊断(0: 良好，1：轻微，2：严重), front_wiper_desc: 前雨刷诊断(0: 正常，1：建议更换，2：未检查),  back_wiper_desc: 后雨刷诊断(0: 正常，1：建议更换，2：未检查)',  :need_user => true, :need_maintain_order => true do
#  it "列举第1页保养记录，每页6个" do
#    response_json = get_json "http://localhost:3000/auto_inspection_report.json?phone_nums[]=13810190339&phone_nums[]=13666666666&page=1&per=6"
#    # 确认调用成功
#    expect(response_json.code).to be(200)
#    orders = JSON.parse(response_json)
#    # 确认返回值正确
#    expect(orders.size).to be > 0
#  end
#
#  it "列举第2页保养记录，到达最后一页" do
#    response_json = get_json "http://localhost:3000/auto_inspection_report.json?phone_nums[]=13888888888&phone_nums[]=13666666666&page=2&per=6"
#    expect(response_json.code).to be(200)
#    orders = JSON.parse(response_json)
#    expect(orders.size).to be(0)
#  end
#end

describe '设置订单属性，包括状态，取消原因等。状态取值：8：服务取消', :need_user => true, :need_login => true, :need_maintain_order => true do
  it "设置订单状态为服务取消，并说明原因为：有事先不做了" do
    # false表示不产生API文档
    response_json = get_json "http://localhost:3000/orders?auth_token=#{@token}&page=1&per=2", false
    expect(response_json.code).to be(200)
    orders = JSON.parse(response_json)
    expect(orders.size).to be > 0
    expect(orders[0]['id']).to be
    
    r = {
      order: {
        state: 8,
        cancel_reason: '有事先不做了'
      }
    }
    response_json = put_json "http://localhost:3000/orders/#{orders[0]['id']}", r
    expect(response_json.code).to be(200)

    response_json = get_json "http://localhost:3000/orders/#{orders[0]['id']}?auth_token=#{@token}", false
    expect(response_json.code).to be(200)
    order = JSON.parse(response_json)
    expect(order['state']).to eq(I18n.t(Order::STATE_STRINGS[8]))
    expect(order['cancel_reason']).to eq('有事先不做了')
  end
end

describe '新建PM2.5滤芯订单，指定朋友手机号。', :need_user => true do
  it "新建保养订单" do
    o = {
      parts: [
              {
                brand: "卡拉丁",
                number: "53672bab9a94e45d440005ae"
              }
      ],
      info: {
              address: "北京朝阳区光华路888号",
              name: "王一迅",
              phone_num: @user.phone_num,
              client_id: "040471abcd",
              car_location: "京",
              car_num: "N333M3",
              serve_datetime: "2014-06-09 15:44",
              pay_type: 1,
              reciept_type: 1,
              reciept_title: "卡拉丁汽车技术",
              client_comment: "请按时到场",
              city_id: City.find_by(name: '北京市').id.to_s,
              friend_phone_num: @weiche_user.phone_num
      }
    }
    c = Client.find_or_create_by phone_num: @weiche_user.phone_num
    expect(c).to be
    old_balance = c.balance.to_f
    response_json = post_json "http://localhost:3000/auto_maintain_order/531f1ed0098e71b3f80001fb.json", o
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
    expect(h['result']).to eq('succeeded')
    expect(h['seq']).to be
    o = Order.find_by(seq: h['seq'])
    expect(o.calc_price.to_f).to be(150.0)
    c = Client.find_by phone_num: @user.phone_num
    expect(c).to be
    c.destroy
    c = Client.find_by phone_num: @weiche_user.phone_num
    expect(c.balance.to_f).to be(old_balance + 50.0)
    c.destroy
    o.destroy
  end
end

describe '查询账户余额。phone_num为客户手机号。balance为余额（单位：元）', :need_user => true do
  it "查询13810190339的账户余额" do
    c = Client.find_or_create_by phone_num: 13810190339
    c.update_attributes balance: 150.0
    response_json = get_json "http://localhost:3000/client_query.json?phone_num=#{c.phone_num}"
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
    expect(h['balance'].to_f).to be(150.0)
    c.destroy
  end
end
