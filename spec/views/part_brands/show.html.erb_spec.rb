require 'spec_helper'

describe "part_brands/show" do
  before(:each) do
    @part_brand = assign(:part_brand, stub_model(PartBrand,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
  end
end
