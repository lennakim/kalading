#encoding: UTF-8
shared_context "order", :need_maintain_order => true do
  before {
    # 测试之前，创建订单
    @order = create(:unscheduled_order)
    asm = AutoSubmodel.first
    @order.update_attributes engineer_id: @user.id, auto_submodel_id: asm.id
    @order.parts << asm.parts.first
    @order.parts << asm.parts.last
    
    @order1 = create(:scheduled_order)
    @order1.update_attributes engineer_id: @user.id, auto_submodel_id: AutoSubmodel.asc(:full_name_pinyin).first.id

    @order2 = create(:serve_done_order)
    @order2.update_attributes engineer_id: @user.id, auto_submodel_id: AutoSubmodel.last.id

    @order3 = create(:revisited_order)
    @order3.update_attributes engineer_id: @user.id, auto_submodel_id: AutoSubmodel.last.id
  }
  
  after {
    # 测试之后，删除订单
    @order.destroy
    @order1.destroy
    @order2.destroy
    @order3.destroy
  }
end