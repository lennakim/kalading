require 'spec_helper'

describe "dynamic_prices/index" do
  before(:each) do
    assign(:dynamic_prices, [
      stub_model(DynamicPrice,
        :price => ""
      ),
      stub_model(DynamicPrice,
        :price => ""
      )
    ])
  end

  it "renders a list of dynamic_prices" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
