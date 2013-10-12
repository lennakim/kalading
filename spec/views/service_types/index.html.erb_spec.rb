require 'spec_helper'

describe "service_types/index" do
  before(:each) do
    assign(:service_types, [
      stub_model(ServiceType,
        :name => "Name"
      ),
      stub_model(ServiceType,
        :name => "Name"
      )
    ])
  end

  it "renders a list of service_types" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
