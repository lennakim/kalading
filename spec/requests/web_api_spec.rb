#encoding: UTF-8
require 'rails_helper'

describe '查询城市的服务能力.返回每天可下单数量。start_date为起始日期，end_date为终止日期。', :type => :request do
  include_context "api doc"
  it "查询北京2014-05-13到2014-06-01的服务能力" do
    get "/city_capacity/#{City.find_by(name: '北京市').id}.json?start_date=2014-05-13&end_date=2014-06-12"
    expect(response).to have_http_status(200)
    a = JSON.parse(response.body)
    expect(a.size).to be > 0
  end
end

describe '查询车型保养套餐', :type => :request do
  include_context "api doc"
  it "查询丰田(一汽) 兰德酷路泽 4.7L 2007.12-2012.02保养套餐" do
    get "/auto_maintain_order/531f1ed0098e71b3f80001fb.json"
    expect(response).to have_http_status(200)
    a = JSON.parse(response.body)
  end
end

describe '查询车辆品牌', :type => :request do
  include_context "api doc"
  it "查询长城" do
    get "/auto_brands/531f1fdb098e71b3f8003522.json"
    expect(response).to have_http_status(200)
  end
end

describe '新建保养订单。city_id为城市的ID，client_id为用户标识（openid）。', :type => :request do
  include_context "api doc"
  it "新建保养订单" do
    o = {
      parts: [
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
    post "/auto_maintain_order/531f1ed0098e71b3f80001fb.json", o
    expect(response).to have_http_status(200)
    h = JSON.parse(response.body)
    expect(h['result']).to eq('succeeded')
    expect(h['seq']).to be
    o = Order.find_by(seq: h['seq'])
    o.destroy
  end
end

describe '查询换空调滤+PM2.5滤芯价格，client_id为用户标识（openid）。', :type => :request do
  include_context "api doc"
  it "查询换空调滤+PM2.5滤芯价格" do
    o = {
      parts: [
              {
                brand: "曼牌 Mann",
                number: "528af433098e7180590042ca"
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
    post "/auto_maintain_price/531f1ed0098e71b3f80001fb.json", o
    expect(response).to have_http_status(200)
    h = JSON.parse(response.body)
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
    get_without_better_doc "/orders", {:page => 1, :per => 2, :format => 'json'}
    expect(response).to have_http_status(200)
    orders = JSON.parse(response.body)
    expect(orders.size).to be > 0
    expect(orders[0]['id']).to be
    
    r = {
      order: {
        state: 8,
        cancel_reason: '有事先不做了'
      }
    }
    put "/orders/#{orders[0]['id']}", r
    expect(response).to have_http_status(200)

    get_without_better_doc "/orders/#{orders[0]['id']}", {:format => 'json'}
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
