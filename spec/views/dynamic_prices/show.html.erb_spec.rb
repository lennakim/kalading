require 'spec_helper'

describe "dynamic_prices/show" do
  before(:each) do
    @dynamic_price = assign(:dynamic_price, stub_model(DynamicPrice,
      :price => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
  end
end
