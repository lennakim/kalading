require 'spec_helper'

describe "parts/index" do
  before(:each) do
    assign(:parts, [
      stub_model(Part,
        :number => "Number",
        :stock_quantity => 1,
        :url => "Url"
      ),
      stub_model(Part,
        :number => "Number",
        :stock_quantity => 1,
        :url => "Url"
      )
    ])
  end

  it "renders a list of parts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Number".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Url".to_s, :count => 2
  end
end
