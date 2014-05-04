#encoding: UTF-8
shared_context "create user", :need_user => true do
  before {
    # 测试之前，创建临时账户
    @user = create(:user)
  }
  
  after {
    # 测试之后，删除账户
    @user.destroy
  }
end