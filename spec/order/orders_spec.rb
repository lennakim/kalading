#encoding: UTF-8
require 'spec_helper'
require 'rest_client'

describe Order, :need_user => true, :need_login => true, :need_maintain_order => true do
  it "should list page 1 of my orders" do
    response_json = RestClient.get "http://localhost:3000/orders?auth_token=#{@token}&page=1", :content_type => :json, :accept => :json
    # 确认调用成功
    expect(response_json.code).to be(200)
    # 打印返回值
    orders = JSON.parse(response_json)
    expect(orders.size).to be > 0
    puts JSON.pretty_generate(JSON.parse(response_json))
  end

  it "should list page 2 of my orders" do
    response_json = RestClient.get "http://localhost:3000/orders?auth_token=#{@token}&page=2", :content_type => :json, :accept => :json
    # 确认调用成功
    expect(response_json.code).to be(200)
    # 打印返回值
    orders = JSON.parse(response_json)
    expect(orders.size).to be(0)
  end

  #it "should create auto test order" do
  #  # API 输入参数
  #  r = { 
  #    info: {
  #      address: "北京朝阳区光华路888号",
  #      name: "王一迅",
  #      phone_num: "13888888888",
  #      car_location: "京",
  #      car_num: "N333M3",
  #      serve_datetime: "2014-03-09 15:44",
  #      pay_type: 1,
  #      reciept_type: 1,
  #      reciept_title: "卡拉丁汽车技术",
  #      client_comment: "请按时到场"
  #    }
  #  }
  #  # API地址为/auto_test_order，HTTP请求类型为POST
  #  response_json = RestClient.post "http://localhost:3000/auto_test_order?auth_token=#{@token}", r.to_json,:content_type => :json, :accept => :json
  #  # 确认调用成功
  #   expect(response_json.code).to be(200)
  #  # 打印返回值
  #  puts JSON.pretty_generate(JSON.parse(response_json))
  #  rs = JSON.parse(response_json)
  #  # 可以对返回值做进一步分析检查
  #end
end