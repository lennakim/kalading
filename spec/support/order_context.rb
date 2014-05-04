#encoding: UTF-8
shared_context "order", :need_maintain_order => true do
  before {
    # 测试之前，创建订单
    @order = create(:maintain_order)
    @order.update_attributes engineer_id: @user.id, auto_submodel_id: AutoSubmodel.first.id
  }
  
  after {
    # 测试之后，删除订单
    @order.destroy
  }
end