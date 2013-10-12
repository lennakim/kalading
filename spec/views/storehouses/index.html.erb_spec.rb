require 'spec_helper'

describe "storehouses/index" do
  before(:each) do
    assign(:storehouses, [
      stub_model(Storehouse,
        :name => "Name",
        :address => "Address",
        :phone_num => "Phone Num"
      ),
      stub_model(Storehouse,
        :name => "Name",
        :address => "Address",
        :phone_num => "Phone Num"
      )
    ])
  end

  it "renders a list of storehouses" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    assert_select "tr>td", :text => "Phone Num".to_s, :count => 2
  end
end
