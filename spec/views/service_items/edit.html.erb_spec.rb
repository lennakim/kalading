require 'spec_helper'

describe "service_items/edit" do
  before(:each) do
    @service_item = assign(:service_item, stub_model(ServiceItem,
      :price => ""
    ))
  end

  it "renders the edit service_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", service_item_path(@service_item), "post" do
      assert_select "input#service_item_price[name=?]", "service_item[price]"
    end
  end
end
