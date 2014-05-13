#encoding: UTF-8
require 'spec_helper'

describe '查询城市的服务能力.返回每天可下单数量。start_date为起始日期，end_date为终止日期。', :need_user => true, :need_login => true, :need_maintain_order => true do
  it "查询2014-05-13到2014-06-01的服务能力" do
    response_json = get_json "http://localhost:3000/city_capacity/#{City.find_by(name: '北京市').id}.json?auth_token=#{@token}&start_date=2014-05-13&end_date=2014-06-12"
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
    expect(h.size).to be > 0
  end
end

describe '查询车型保养套餐', :need_user => true, :need_login => true do
  it "查询丰田(一汽) 兰德酷路泽 4.7L 2007.12-2012.02保养套餐" do
    response_json = get_json "http://localhost:3000/auto_maintain_order/531f1ed0098e71b3f80001fb.json?auth_token=#{@token}"
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
    #expect(h['result']).to eq('succeeded')
    #expect(h['seq']).to be
  end
end

describe '新建保养订单。city_id为城市的ID', :need_user => true, :need_login => true do
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
    response_json = post_json "http://localhost:3000/auto_maintain_order/#{AutoSubmodel.first.id}.json?auth_token=#{@token}", o
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
    expect(h['result']).to eq('succeeded')
    expect(h['seq']).to be
    Order.find_by(seq: h['seq']).destroy
  end
end
