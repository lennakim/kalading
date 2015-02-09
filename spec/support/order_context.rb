#encoding: UTF-8
shared_context "order", :need_maintain_order => true do
  before {
    # 测试之前，创建临时账户
    @user = create(:user)
    # 登录
    post "/users/sign_in", {:phone_num => @user.phone_num, :password => @user.password, :format => 'json'}
    expect(response.status).to be(201)
    @token = JSON.parse(response.body)["authentication_token"]
    expect(@token).not_to be(nil)

    # 测试之前，创建订单
    @order = create(:unscheduled_order)
    asm = AutoSubmodel.first
    @order.update_attributes auto_submodel_id: asm.id
    @order.parts << asm.parts.first
    @order.parts << asm.parts.last
    
    @order2 = create(:serve_done_order)
    @order2.update_attributes auto_submodel_id: AutoSubmodel.last.id

    @order3 = create(:revisited_order)
    @order3.update_attributes auto_submodel_id: AutoSubmodel.last.id

    @order1 = create(:scheduled_order)
    @order1.update_attributes auto_submodel_id: AutoSubmodel.find('549e31c0255188a28a00169f').id
  }
  
  after {
    # 测试之后，删除订单
    @order.destroy
    @order1.destroy
    @order2.destroy
    @order3.destroy
    @user.destroy
  }
end