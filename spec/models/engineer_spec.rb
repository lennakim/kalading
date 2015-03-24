require 'rails_helper'

RSpec.describe Engineer, :type => :model do

  it "should be type of User" do
    user = build(:engineer)
    user.class.should == Engineer
    user._type.should == "Engineer"
    user.should === User
  end

  it "should be role of engineer" do
    user = build :engineer
    user.should be_engineer
  end

  it "should be accessed by right role" do
    pending "技师管理界面的访问权限"
  end

end
