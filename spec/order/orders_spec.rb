#encoding: UTF-8
require 'spec_helper'
require 'rest_client'

describe "POST 'orders'" do
  it "should create orders" do
    # API 输入参数
    r = { 
      info: {
        address: "北京朝阳区光华路888号",
        name: "王一迅",
        phone_num: "13888888888",
        car_location: "京",
        car_num: "N333M3",
        serve_datetime: "2014-03-09 15:44",
        pay_type: 1,
        reciept_type: 1,
        reciept_title: "卡拉丁汽车技术",
        client_comment: "请按时到场"
      }
    }
    # API地址为/auto_test_order，HTTP请求类型为POST
    response_json = RestClient.post "http://localhost:3000/auto_test_order", r.to_json,:content_type => :json, :accept => :json
    # 确认调用成功
    response_json.code.should == 200
    # 打印返回值
    puts response_json
    rs = JSON.parse(response_json)
    # 可以对返回值做进一步分析检查
  end
end