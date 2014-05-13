#encoding: UTF-8
require 'spec_helper'

describe '查询城市的服务能力.返回每天可下单数量。start_date为起始日期，end_date为终止日期。', :need_user => true, :need_login => true, :need_maintain_order => true do
  it "查询2014-05-13到2014-06-12的服务能力" do
    response_json = get_json "http://localhost:3000/city_capacity/#{City.find_by(name: '北京市').id}.json?auth_token=#{@token}&start_date=2014-05-13&end_date=2014-06-12"
    expect(response_json.code).to be(200)
    h = JSON.parse(response_json)
    expect(h.size).to be > 0
  end
end
