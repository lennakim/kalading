require 'spec_helper'

describe "auto_brands/index" do
  before(:each) do
    assign(:auto_brands, [
      stub_model(AutoBrand,
        :name => "Name"
      ),
      stub_model(AutoBrand,
        :name => "Name"
      )
    ])
  end

  it "renders a list of auto_brands" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
