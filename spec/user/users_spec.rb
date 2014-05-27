#encoding: UTF-8
require 'spec_helper'
require 'rest_client'

describe '用户登录，返回authentication_token用于其它API调用', :need_user=> true do
  it "登录成功，返回authentication_token和用户名" do
    response_json = post_json "http://localhost:3000/users/sign_in", {:phone_num => @user.phone_num, :password => @user.password}
    expect(response_json.code).to be(201)
    token = JSON.parse(response_json)["authentication_token"]
    expect(token).not_to be(nil)
    name = JSON.parse(response_json)["name"]
    expect(name).not_to be(nil)
  end

  it "登录失败，返回错误信息: 密码错误" do
    response_json = post_json "http://localhost:3000/users/sign_in", {:phone_num => @user.phone_num, :password => 'incorrect password'}
    expect(response_json.code).to be(200)
    expect(JSON.parse(response_json)["result"]).not_to eq('ok')
  end
end

describe '用户注销', :need_user=> true do
  it "注销成功" do
    response_json = post_json "http://localhost:3000/users/sign_in", {:phone_num => @user.phone_num, :password => @user.password}
    token = JSON.parse(response_json)["authentication_token"]
    expect(token).not_to be(nil)
    response_json = delete_json "http://localhost:3000/users/sign_out?auth_token=#{token}"
    expect(response_json.code).to be(200)
    r = JSON.parse(response_json)["result"]
    expect(r).to eq('ok')
  end
end