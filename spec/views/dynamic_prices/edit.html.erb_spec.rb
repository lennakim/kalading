require 'spec_helper'

describe "dynamic_prices/edit" do
  before(:each) do
    @dynamic_price = assign(:dynamic_price, stub_model(DynamicPrice,
      :price => ""
    ))
  end

  it "renders the edit dynamic_price form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", dynamic_price_path(@dynamic_price), "post" do
      assert_select "input#dynamic_price_price[name=?]", "dynamic_price[price]"
    end
  end
end
