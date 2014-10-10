#encoding: UTF-8
require 'spec_helper'

describe '用户登录，返回authentication_token用于其它API调用', :need_user => true do
  it "登录成功，返回authentication_token" do
    response_json = post_json "http://localhost:3000/users/sign_in", {:phone_num => @baichebao_user.phone_num, :password => @baichebao_user.password}
    expect(response_json.code).to be(201)
    token = JSON.parse(response_json)["authentication_token"]
    expect(token).not_to be(nil)
  end
end

describe '查询某个车型的保养默认套餐和适用配件信息。auth_token为登录返回的token。applicable_parts为所有适用配件的信息，包括品牌，ID，价格。', :need_user => true, :need_login => true, :need_maintain_order => true do
  it "查询车型531f1ed0098e71b3f80001fb的保养套餐" do
    response_json = get_json "http://localhost:3000/auto_maintain_order/531f1ed0098e71b3f80001fb.json?auth_token=#{@baichebao_token}"
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
  end
end

describe '新建百车宝保养订单，需指定车型ID。parts为用户选择的配件,配件的brand和number从查询套餐的接口获得。返回值seq为订单唯一标识，用于订单状态通知。输入参数：serve_datetime为期望的上门服务时间。pay_type为支付方式，0为现金，1为刷卡；reciept_type为发票类型，0为个人，1为公司。', :need_user => true, :need_login => true, :need_maintain_order => true do
  it "新建保养订单成功" do
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
              }
      ],
      info: {
              address: "客户地址信息",
              name: "客户姓名",
              phone_num: "13888888888",
              car_location: "京",
              car_num: "N333M3",
              serve_datetime: "2014-06-09 15:44",
              pay_type: 1,
              reciept_type: 1,
              reciept_title: "发票抬头",
              client_comment: "客户的特殊要求",
      }
    }
    response_json = post_json "http://localhost:3000/auto_maintain_pack/531f1ed0098e71b3f80001fb.json?auth_token=#{@baichebao_token}", o
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
    expect(h['result']).to eq('succeeded')
    expect(h['seq']).to be
    o = Order.find_by(seq: h['seq'])
    expect(o.parts.count).to be(3)
    expect(o.calc_price.to_f).not_to be(0.0)
    expect(o.city.name).to eq('北京市')
    expect(o.user_type.name).to eq('百车宝')
    o.destroy
  end
end

