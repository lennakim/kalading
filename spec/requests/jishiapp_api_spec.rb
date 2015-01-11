#encoding: UTF-8
require 'rails_helper'

describe '用户登录，返回authentication_token用于其它API调用',  :type => :request do
  include_context "order"
  include_context "api doc"

  it "登录成功，返回authentication_token" do
    post "/users/sign_in", {:phone_num => @user.phone_num, :password => @user.password, :format => 'json'}
    expect(response).to have_http_status(201)
    token = JSON.parse(response.body)["authentication_token"]
    expect(token).not_to be(nil)
  end
end

describe '用户注销',  :type => :request do
  include_context "order"
  include_context "api doc"

  it "注销成功，返回{'result' : 'ok'}" do
    delete "/users/sign_out?auth_token=#{@user.authentication_token}", {:format => 'json'}
    expect(response).to have_http_status(200)
    h = JSON.parse(response.body)
    puts h
    expect(h['result']).to eq('ok')
  end
end

describe '订单列表,支持分页，page为页数（从1开始），per为每页返回的订单个数，auth_token为登录时返回的token。返回空表示到达最后一页。 asm_pics为车型图文列表，url为图片url，bytes为图片大小字节数，desc为图片的描述', :type => :request do
  include_context "order"
  include_context "api doc"
  
  it "列举第1页订单，每页2个" do
    get "/orders", {:page => 1, :per => 2}
    expect(response).to have_http_status(200)
    orders = JSON.parse(response.body)
    expect(orders.size).to be > 0
  end

  it "列举第3页订单，到达最后一页" do
    get "/orders", {:page => 3, :per => 2, :format => 'json'}
    expect(response).to have_http_status(200)
    orders = JSON.parse(response.body)
    expect(orders.size).to be(0)
  end
end

describe '设置订单属性，包括状态，取消原因，服务时间等。状态取值：3: 未预约，4： 已预约，5: 服务完成，8：服务取消', :type => :request do
  include_context "order"
  include_context "api doc"

  it "设置订单状态为服务取消，并说明原因为：客户联系不上" do
    # false表示本次请求不产生API文档
    get_without_better_doc "/orders", {:page => 1, :per => 2, :format => 'json'}
    expect(response).to have_http_status(200)
    orders = JSON.parse(response.body)
    expect(orders.size).to be > 0
    expect(orders[0]['id']).to be
    
    r = {
      order: {
        state: 8,
        cancel_reason: '客户联系不上'
      }
    }
    put "/orders/#{orders[0]['id']}", r
    expect(response).to have_http_status(200)

    get_without_better_doc "/orders/#{orders[0]['id']}", {:format => 'json'}
    expect(response).to have_http_status(200)
    order = JSON.parse(response.body)
    expect(order['state']).to eq(I18n.t(Order::STATE_STRINGS[8]))
    expect(order['cancel_reason']).to eq('客户联系不上')
  end

  it "设置订单状态为已预约，并修改服务时间" do
    get_without_better_doc "/orders", {:page => 1, :per => 2, :format => 'json'}
    expect(response).to have_http_status(200)
    orders = JSON.parse(response.body)
    expect(orders.size).to be > 0
    expect(orders[0]['id']).to be
    
    r = {
      order: {
        state: 4,
        serve_datetime: '2014-05-08 14:00'
      }
    }
    put "/orders/#{orders[0]['id']}", r
    expect(response).to have_http_status(200)

    get_without_better_doc "/orders/#{orders[0]['id']}", {:format => 'json'}
    expect(response).to have_http_status(200)
    order = JSON.parse(response.body)
    expect(order['state']).to eq(I18n.t(Order::STATE_STRINGS[4]))
    expect(order['serve_datetime']).to eq('2014-05-08 14:00')
  end

  it "完成订单" do
    get_without_better_doc "/orders", {:page => 1, :per => 2, :format => 'json'}
    expect(response).to have_http_status(200)
    orders = JSON.parse(response.body)
    expect(orders.size).to be > 0
    expect(orders[0]['id']).to be
    
    r = {
      order: {
        state: 5,
        serve_datetime: '2014-05-08 14:00',
        serve_end_datetime: '2014-05-08 16:00'
      }
    }
    put "/orders/#{orders[0]['id']}", r
    expect(response).to have_http_status(200)

    get_without_better_doc "/orders/#{orders[0]['id']}", {:format => 'json'}
    expect(response).to have_http_status(200)
    order = JSON.parse(response.body)
    expect(order['state']).to eq(I18n.t(Order::STATE_STRINGS[5]))
    expect(order['serve_datetime']).to eq('2014-05-08 14:00')
    expect(order['serve_end_datetime']).to eq('2014-05-08 16:00')
  end
end