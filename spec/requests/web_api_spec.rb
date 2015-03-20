#encoding: UTF-8
require 'rails_helper'

describe '查询城市的服务能力.返回每天可下单数量。start_date为起始日期，end_date为终止日期。', :type => :request do
  include_context "api doc"
  let(:city) {create(:beijing)}
  it "查询北京2014-05-13到2014-06-01的服务能力" do
    get "/city_capacity/#{city.id}.json?start_date=2014-05-13&end_date=2014-06-12"
    expect(response).to have_http_status(200)
    a = JSON.parse(response.body)
    expect(a.size).to be > 0
  end
end

describe '查询车型保养套餐', :type => :request do
  include_context "api doc"
  let(:auto_maintain) { create(:auto_maintain) }
  let(:asm) {create(:audi_a3_20_2012)}
  it "查询奥迪A3 2.0TFSI 2012-2014保养套餐" do
    auto_maintain
    get "/auto_maintain_order/#{asm.id}.json"
    expect(response).to have_http_status(200)
    a = JSON.parse(response.body)
    a
  end
end

describe '新建保养订单。city_id为城市的ID。', :type => :request do
  include_context "api doc"
  let(:city) {create(:beijing)}
  let(:asm) {create(:audi_a3_20_2012)}
  let(:mann_part) { create(:mann_part) }
  let(:auto_maintain) { create(:auto_maintain) }
  it "新建保养订单" do
    auto_maintain
    o = {
      parts: [
              {
                brand: mann_part.part_brand.name,
                number: mann_part.id
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
              city_id: city.id
      }
    }
    post "/auto_maintain_order/#{asm.id}.json", o
    expect(response).to have_http_status(200)
    h = JSON.parse(response.body)
    expect(h['result']).to eq('succeeded')
    expect(h['seq']).to be
    o = Order.find_by(seq: h['seq'])
    o.destroy
  end
end

describe '新建保养订单，服务项目为保养。city_id为城市的ID。', :type => :request do
  include_context "api doc"
  let(:city) {create(:beijing)}
  let(:asm) {create(:audi_a3_20_2012)}
  let(:mann_part) { create(:mann_part) }
  let(:auto_maintain) { create(:auto_maintain) }
  it "新建保养订单" do
    auto_maintain
    o = {
      service_type: 1,
      parts: [
              {
                brand: mann_part.part_brand.name,
                number: mann_part.id
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
              city_id: city.id
      }
    }
    post "/auto_maintain_order/#{asm.id}.json", o
    expect(response).to have_http_status(200)
    h = JSON.parse(response.body)
    expect(h['result']).to eq('succeeded')
    expect(h['seq']).to be
    o = Order.find_by(seq: h['seq'])
    expect(o.service_types.first).to eq(auto_maintain)
    o.destroy
  end
end

describe '查询价格。', :type => :request do
  include_context "api doc"
  let(:city) {create(:beijing)}
  let(:asm) {create(:audi_a3_20_2012)}
  let(:mann_part) { create(:mann_part) }
  let(:auto_maintain) { create(:auto_maintain) }
  it "查询换空调滤+PM2.5滤芯价格" do
    auto_maintain
    o = {
      parts: [
              {
                brand: mann_part.part_brand.name,
                number: mann_part.id
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
              city_id: city.id
      }
    }
    post "/auto_maintain_price/#{asm.id}.json", o
    expect(response).to have_http_status(200)
    h = JSON.parse(response.body)
    h
  end
end

describe '查询价格，服务项目为保养。', :type => :request do
  include_context "api doc"
  let(:city) {create(:beijing)}
  let(:asm) {create(:audi_a3_20_2012)}
  let(:mann_part) { create(:mann_part) }
  let(:auto_maintain) { create(:auto_maintain) }
  it "查询换空调滤+PM2.5滤芯价格" do
    auto_maintain
    o = {
      service_type: 1,
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
              city_id: city.id
      }
    }
    post "/auto_maintain_price/#{asm.id}.json", o
    expect(response).to have_http_status(200)
    h = JSON.parse(response.body)
    expect(h['price']).to eq(auto_maintain.price)
  end
end

describe '查询多个手机号的订单列表，phone_nums为手机号列表。支持分页，page为页数（从1开始），per为每页返回的订单个数。返回空表示到达最后一页。', :type => :request do
  include_context "order"
  include_context "api doc"
  it "列举第1页订单，每页6个" do
    get "/orders.json?phone_nums[]=13888888888&phone_nums[]=13666666666&page=1&per=6"
    expect(response).to have_http_status(200)
    h = JSON.parse(response.body)
    expect(h.size).to be > 0
  end

  it "列举第100页订单，到达最后一页" do
    get "/orders.json?phone_nums[]=13888888888&phone_nums[]=13666666666&page=100&per=6"
    expect(response).to have_http_status(200)
    h = JSON.parse(response.body)
    expect(h.size).to eq(0)
  end
end

describe '设置订单属性，包括状态，取消原因等。状态取值：8：服务取消', :type => :request do
  include_context "order"
  include_context "api doc"
  it "设置订单状态为服务取消，并说明原因为：有事先不做了" do
    r = {
      order: {
        state: 8,
        cancel_reason: '有事先不做了'
      }
    }
    put "/orders/#{@order.id}", r
    expect(response).to have_http_status(200)

    get_without_better_doc "/orders/#{@order.id}", {:format => 'json'}
    expect(response).to have_http_status(200)
    order = JSON.parse(response.body)
    expect(order['state']).to eq(I18n.t(Order::STATE_STRINGS[8]))
    expect(order['cancel_reason']).to eq('有事先不做了')
  end
end

describe '查询账户余额。phone_num为客户手机号。balance为余额（单位：元）', :type => :request do
  include_context "api doc"
  it "查询13810190339的账户余额" do
    c = Client.find_or_create_by phone_num: 13810190339
    c.update_attributes balance: 150.0
    get "/client_query.json?phone_num=#{c.phone_num}"
    expect(response).to have_http_status(200)
    h = JSON.parse(response.body)
    expect(h['balance'].to_f).to eq(150.0)
    c.destroy
  end
end

describe '城市', :type => :request do
  include_context "api doc"
  let(:city) {create(:beijing)}
  it "查询城市列表" do
    city
    get "/cities.json"
    expect(response).to have_http_status(200)
    a = JSON.parse(response.body)
    expect(a.size).to be > 0
    a.each do |c|
      expect(c['districts'].size).to be > 0
    end
  end
end

describe '保养记录', :type => :request do
  include_context "order"
  include_context "api doc"
  let(:maintain) {create(:maintain)}
  it "查询13666666666的保养记录" do
    expect(maintain).to be
    get "/auto_inspection_report.json", {:format => 'json', :login_phone_num => '13666666666'}
    expect(response).to have_http_status(200)
    a = JSON.parse(response.body)
    expect(a.size).to be > 0
    a.each do |m|
      expect(m['serve_datetime'].size).not_to eq(0)
      expect(m['car_id']).to eq('')
    end
  end
end
