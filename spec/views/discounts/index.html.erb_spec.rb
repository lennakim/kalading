require 'spec_helper'

describe "discounts/index" do
  before(:each) do
    assign(:discounts, [
      stub_model(Discount,
        :name => "Name",
        :discount => "",
        :percent => 1
      ),
      stub_model(Discount,
        :name => "Name",
        :discount => "",
        :percent => 1
      )
    ])
  end

  it "renders a list of discounts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
