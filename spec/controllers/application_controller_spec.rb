#encoding: UTF-8
require 'rails_helper'

describe ApplicationController do
  describe "经纬度查询" do
    let(:lng_lat1) { Map.get_latitude_longitude '北京市', '北苑家园' }

    it "查询北京市北苑家园经纬度，返回[116.422081, 40.047041]" do
      expect(lng_lat1).to be_instance_of(Array)
      expect(lng_lat1.size).to eq(2)
    end

  end

  describe "距离计算" do
    let(:lng_lat1) { Map.get_latitude_longitude '北京市', '北苑家园' }
    let(:lng_lat2) { Map.get_latitude_longitude '北京市', '峻峰华亭' }
    let(:distance) { Map.haversine_distance lng_lat1, lng_lat2 }

    it "计算北苑家园到峻峰华亭的距离，6849.084151839044米" do
      expect(distance).to be_instance_of(Float)
      expect(distance).to be > 0
    end
  end

  describe "发送短信" do
    it "发送短信" do
      # 云片网有IP白名单，短信不会真的发
      subject.send_sms '13810190339', '647223', "#reason#=test"
    end
  end
end
  