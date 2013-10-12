require 'spec_helper'

describe "service_items/index" do
  before(:each) do
    assign(:service_items, [
      stub_model(ServiceItem,
        :price => ""
      ),
      stub_model(ServiceItem,
        :price => ""
      )
    ])
  end

  it "renders a list of service_items" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
