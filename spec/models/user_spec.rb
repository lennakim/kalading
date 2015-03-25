require 'rails_helper'

describe User do

  it "should work" do
    expect(1).to eq(1)
  end

  it "should have roles methods" do
    user = build(:user)
    user.roles = ["0"]

    user.should be_customer
    user.should_not be_role_admin

    user.roles = ["1"]
    user.should_not be_customer
    user.should be_role_admin
  end

  it "should have state methods" do
    user = build :user

    user.state = 1
    user.should be_offline

    user.state = 0
    user.should be_online
  end

end
