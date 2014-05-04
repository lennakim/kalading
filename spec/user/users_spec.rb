#encoding: UTF-8
require 'spec_helper'
require 'rest_client'

describe User, :need_user=> true do
  it "should sign in" do
    response_json = RestClient.post "http://localhost:3000/users/sign_in", {:phone_num => @user.phone_num, :password => @user.password}.to_json, :content_type => :json, :accept => :json
    expect(response_json.code).to be(201)
    token = JSON.parse(response_json)["authentication_token"]
    expect(token).not_to be(nil)
    puts JSON.pretty_generate(JSON.parse(response_json))
  end

  it "should sign out" do
    response_json = RestClient.post "http://localhost:3000/users/sign_in", {:phone_num => @user.phone_num, :password => @user.password}.to_json, :content_type => :json, :accept => :json
    token = JSON.parse(response_json)["authentication_token"]
    expect(token).not_to be(nil)
    response_json = RestClient.delete "http://localhost:3000/users/sign_out?auth_token=#{token}", :accept => :json
    expect(response_json.code).to be(204)
  end
end