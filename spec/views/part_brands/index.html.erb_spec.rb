require 'spec_helper'

describe "part_brands/index" do
  before(:each) do
    assign(:part_brands, [
      stub_model(PartBrand,
        :name => "Name"
      ),
      stub_model(PartBrand,
        :name => "Name"
      )
    ])
  end

  it "renders a list of part_brands" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
