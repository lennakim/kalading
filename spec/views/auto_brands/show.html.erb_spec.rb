require 'spec_helper'

describe "auto_brands/show" do
  before(:each) do
    @auto_brand = assign(:auto_brand, stub_model(AutoBrand,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
  end
end
