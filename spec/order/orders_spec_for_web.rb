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
    Order.find_by(seq: h['seq']).destroy
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
    expect(o.price.to_f).to be(50.0)
    o.destroy
  end
end

describe '新建PM2.5滤芯订单，client_id为用户标识（openid）。', :need_user => true do
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
    expect(o.price.to_f).to be(50.0)
    o.destroy
  end
end

describe '读取某个客户的订单列表，client_id为客户标识（openid）。支持分页，page为页数（从1开始），per为每页返回的订单个数。返回空表示到达最后一页。', :need_user => true, :need_maintain_order => true do
  it "列举第1页订单，每页4个" do
    response_json = get_json "http://localhost:3000/orders.json?client_id=0a0b7D0C1MNP&page=1&per=4"
    # 确认调用成功
    expect(response_json.code).to be(200)
    orders = JSON.parse(response_json)
    # 确认返回值正确
    expect(orders.size).to be > 0
  end

  it "列举第2页订单，到达最后一页" do
    response_json = get_json "http://localhost:3000/orders.json?client_id=0a0b7D0C1MNP&page=2&per=4"
    expect(response_json.code).to be(200)
    orders = JSON.parse(response_json)
    expect(orders.size).to be(0)
  end
end
