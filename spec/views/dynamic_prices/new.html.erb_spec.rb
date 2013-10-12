require 'spec_helper'

describe "dynamic_prices/new" do
  before(:each) do
    assign(:dynamic_price, stub_model(DynamicPrice,
      :price => ""
    ).as_new_record)
  end

  it "renders new dynamic_price form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", dynamic_prices_path, "post" do
      assert_select "input#dynamic_price_price[name=?]", "dynamic_price[price]"
    end
  end
end
