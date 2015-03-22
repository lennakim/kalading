#encoding: UTF-8
require 'rails_helper'

describe OrdersController do
  login_admin
  describe "订单地址经纬度自动查询" do
    let(:city) { create(:beijing) }
    let(:order) { create(:unscheduled_order) }    
    it "新建订单时自动查询经纬度" do
      expect(subject.current_user).to be
      a = '北苑家园'
      map_double = class_double("Map").as_stubbed_const
      expect(map_double).to receive(:get_latitude_longitude).with(city.name, a).and_return([1.1, 2.2])
      post 'create', :format => :json,
        :order => { :name => '三胖', :address => a, :phone_num => '13810101010', :city_id => city.id}
      expect(response).to have_http_status(201)
      h = JSON.parse(response.body)
      expect(h['_id']).to be
    end

    it "修改订单时自动更新经纬度" do
      expect(subject.current_user).to be
      map_double = class_double("Map").as_stubbed_const
      lng_lats = [[1.1, 2.2], [3.3, 4.4]]
      expect(map_double).to receive(:get_latitude_longitude).and_return(*lng_lats)
      expect(order.location).to eq(lng_lats[0])
      put 'update', :format => :json, :id => order.id,
        :order => { :address => '北苑家园'}
      expect(response).to have_http_status(200)
      h = JSON.parse(response.body)
      expect(h['result']).to eq('ok')
      order.reload
      expect(order.location).to eq(lng_lats[1])
    end
  end
end
  