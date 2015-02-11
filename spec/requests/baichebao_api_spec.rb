#encoding: UTF-8
require 'rails_helper'

describe '用户登录，返回authentication_token用于其它API调用',  :type => :request do
  include_context "order"
  include_context "api doc"
  it "登录成功，返回authentication_token" do
    post "/users/sign_in", {:phone_num => user.phone_num, :password => user.password, :format => 'json'}
    expect(response).to have_http_status(201)
    token = JSON.parse(response.body)["authentication_token"]
    expect(token).not_to be(nil)
  end
end

describe '查询某个车型的保养默认套餐和适用配件信息。auth_token为登录返回的token。applicable_parts为所有适用配件的信息，包括品牌，ID，价格。',  :type => :request do
  include_context "order"
  include_context "api doc"
  it "查询奥迪A3保养套餐" do
    get "/auto_maintain_order/#{asm.id}.json"
    expect(response).to have_http_status(200)
  end
end

describe '新建百车宝保养订单，城市北京，需指定车型ID。parts为用户选择的配件,配件的brand和number从查询套餐的接口获得。返回值seq为订单唯一标识，用于订单状态通知。输入参数：serve_datetime为期望的上门服务时间。pay_type为支付方式，0为现金，1为刷卡；reciept_type为发票类型，0为个人，1为公司。',  :type => :request do
  include_context "order"
  include_context "api doc"
  it "新建保养订单成功" do
    o = {
      parts: [
              {
                brand: mann_part.part_brand.name,
                number: mann_part.id
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
              city_id: city.id,
      }
    }
    post "/auto_maintain_pack/#{asm.id}?auth_token=#{@token}", o
    expect(response).to have_http_status(200)
    h = JSON.parse(response.body)
    expect(h['result']).to eq('succeeded')
    expect(h['seq']).to be
    o = Order.find_by(seq: h['seq'])
    expect(o.parts.count).to be(1)
    expect(o.calc_price.to_f).not_to be(0.0)
    expect(o.city.name).to eq('北京市')
    expect(o.user_type.name).to eq('百车宝')
    o.destroy
  end
end

