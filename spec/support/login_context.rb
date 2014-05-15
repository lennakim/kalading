#encoding: UTF-8
shared_context "login", :need_login => true do
  before {
    # 测试之前登录
    response_json = RestClient.post "http://localhost:3000/users/sign_in", {:phone_num => @user.phone_num, :password => @user.password}.to_json, :content_type => :json, :accept => :json
    expect(response_json.code).to be(201)
    @token = JSON.parse(response_json)["authentication_token"]
    expect(@token).not_to be(nil)

    response_json = RestClient.post "http://localhost:3000/users/sign_in", {:phone_num => @baichebao_user.phone_num, :password => @baichebao_user.password}.to_json, :content_type => :json, :accept => :json
    expect(response_json.code).to be(201)
    @baichebao_token = JSON.parse(response_json)["authentication_token"]
    expect(@baichebao_token).not_to be(nil)
  }
end