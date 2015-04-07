#encoding: UTF-8
require 'rails_helper'

describe ApplicationController do
  describe "发送短信" do
    it "发送短信" do
      # 云片网有IP白名单，短信不会真的发
      subject.send_sms '13810190339', '647223', "#reason#=test"
    end
  end
end
  