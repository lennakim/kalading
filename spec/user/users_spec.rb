#encoding: UTF-8
require 'spec_helper'
require 'rest_client'

describe User do
  before (:all) {
    @user = create(:user)  
  }
  
  after (:all) {
    @user.destroy
  }

  it "should sign in" do
    response_json = RestClient.post "http://localhost:3000/users/sign_in", {:phone_num => "13988888888", :password => "12345678"}.to_json, :content_type => :json, :accept => :json
    token = JSON.parse(response_json)["authentication_token"]
    token.should be
    p token
    p response_json
  end

  it "should sign out" do
    response_json = RestClient.post "http://localhost:3000/users/sign_in", {:phone_num => "13988888888", :password => "12345678"}.to_json, :content_type => :json, :accept => :json
    token = JSON.parse(response_json)["authentication_token"]
    token.should_not == nil
    p token
    response_json = RestClient.delete "http://localhost:3000/users/sign_out?auth_token=#{token}", :accept => :json
    response_json.code.should == 204
  end
end