#encoding: UTF-8
shared_context "order", :need_maintain_order => true do
  let(:user) {create(:user)}
  let(:city) {create(:beijing)}
  let(:asm) {create(:audi_a3_20_2012)}
  let(:mann_part) { create(:mann_part) }
  let(:auto_maintain) { create(:auto_maintain) }
  before {
    # 登录
    post "/users/sign_in", {:phone_num => user.phone_num, :password => user.password, :format => 'json'}
    expect(response.status).to be(201)
    @token = JSON.parse(response.body)["authentication_token"]
    expect(@token).not_to be(nil)

    # 测试之前，创建订单
    @order = create(:unscheduled_order)
    @order2 = create(:serve_done_order)
    @revisited_order = create(:revisited_order)
    @order1 = create(:scheduled_order)
  }
  
  after {
  }
end