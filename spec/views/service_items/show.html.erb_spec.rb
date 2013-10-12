require 'spec_helper'

describe "service_items/show" do
  before(:each) do
    @service_item = assign(:service_item, stub_model(ServiceItem,
      :price => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
  end
end
