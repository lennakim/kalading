require 'spec_helper'

describe "orders/index" do
  before(:each) do
    assign(:orders, [
      stub_model(Order,
        :state => "State",
        :address => "Address",
        :phone_num => "Phone Num",
        :buymyself => false
      ),
      stub_model(Order,
        :state => "State",
        :address => "Address",
        :phone_num => "Phone Num",
        :buymyself => false
      )
    ])
  end

  it "renders a list of orders" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "State".to_s, :count => 2
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    assert_select "tr>td", :text => "Phone Num".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
