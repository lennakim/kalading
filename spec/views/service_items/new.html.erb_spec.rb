require 'spec_helper'

describe "service_items/new" do
  before(:each) do
    assign(:service_item, stub_model(ServiceItem,
      :price => ""
    ).as_new_record)
  end

  it "renders new service_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", service_items_path, "post" do
      assert_select "input#service_item_price[name=?]", "service_item[price]"
    end
  end
end
