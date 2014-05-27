#encoding: UTF-8
require 'spec_helper'

# :need_user表示测试之前执行user_context.rb创建用户，并使用get_json, put_json, post_json等API
# :need_login表示测试之前执行login_context.rb登录，设置@token
# :need_maintain_order表示测试之前执行order_context.rb创建订单
describe '订单列表,支持分页，page为页数（从1开始），per为每页返回的订单个数，auth_token为登录时返回的token。返回空表示到达最后一页。 id用于订单的修改', :need_user => true, :need_login => true, :need_maintain_order => true do
  it "列举第1页订单，每页2个" do
    response_json = get_json "http://localhost:3000/orders?auth_token=#{@token}&page=1&per=2"
    # 确认调用成功
    expect(response_json.code).to be(200)
    orders = JSON.parse(response_json)
    # 确认返回值正确
    expect(orders.size).to be > 0
  end

  it "列举第3页订单，到达最后一页" do
    response_json = get_json "http://localhost:3000/orders?auth_token=#{@token}&page=3&per=2"
    expect(response_json.code).to be(200)
    orders = JSON.parse(response_json)
    expect(orders.size).to be(0)
  end
end

describe '设置订单属性，包括状态，取消原因，服务时间等。状态取值：3: 未预约，4： 已预约，5: 服务完成，8：服务取消', :need_user => true, :need_login => true, :need_maintain_order => true do
  it "设置订单状态为服务取消，并说明原因为：客户联系不上" do
    # false表示不产生API文档
    response_json = get_json "http://localhost:3000/orders?auth_token=#{@token}&page=1&per=2", false
    expect(response_json.code).to be(200)
    orders = JSON.parse(response_json)
    expect(orders.size).to be > 0
    expect(orders[0]['id']).to be
    
    r = {
      order: {
        state: 8,
        cancel_reason: '客户联系不上'
      }
    }
    response_json = put_json "http://localhost:3000/orders/#{orders[0]['id']}?auth_token=#{@token}", r
    expect(response_json.code).to be(200)

    response_json = get_json "http://localhost:3000/orders/#{orders[0]['id']}?auth_token=#{@token}", false
    expect(response_json.code).to be(200)
    order = JSON.parse(response_json)
    expect(order['state']).to eq(I18n.t(Order::STATE_STRINGS[8]))
    expect(order['cancel_reason']).to eq('客户联系不上')
  end

  it "设置订单状态为已预约，并修改服务时间" do
    response_json = get_json "http://localhost:3000/orders?auth_token=#{@token}&page=1&per=2", false
    expect(response_json.code).to be(200)
    orders = JSON.parse(response_json)
    expect(orders.size).to be > 0
    expect(orders[0]['id']).to be
    
    r = {
      order: {
        state: 4,
        serve_datetime: '2014-05-08 14:00'
      }
    }
    response_json = put_json "http://localhost:3000/orders/#{orders[0]['id']}?auth_token=#{@token}", r
    expect(response_json.code).to be(200)

    response_json = get_json "http://localhost:3000/orders/#{orders[0]['id']}?auth_token=#{@token}", false
    expect(response_json.code).to be(200)
    order = JSON.parse(response_json)
    expect(order['state']).to eq(I18n.t(Order::STATE_STRINGS[4]))
    expect(order['serve_datetime']).to eq('05-08 14:00')
  end

  it "完成订单" do
    response_json = get_json "http://localhost:3000/orders?auth_token=#{@token}&page=1&per=2", false
    expect(response_json.code).to be(200)
    orders = JSON.parse(response_json)
    expect(orders.size).to be > 0
    expect(orders[0]['id']).to be
    
    r = {
      order: {
        state: 5,
      }
    }
    response_json = put_json "http://localhost:3000/orders/#{orders[0]['id']}?auth_token=#{@token}", r
    expect(response_json.code).to be(200)

    response_json = get_json "http://localhost:3000/orders/#{orders[0]['id']}?auth_token=#{@token}", false
    expect(response_json.code).to be(200)
    order = JSON.parse(response_json)
    expect(order['state']).to eq(I18n.t(Order::STATE_STRINGS[5]))
  end
end