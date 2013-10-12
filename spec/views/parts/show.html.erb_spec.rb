require 'spec_helper'

describe "parts/show" do
  before(:each) do
    @part = assign(:part, stub_model(Part,
      :number => "Number",
      :stock_quantity => 1,
      :url => "Url"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Number/)
    rendered.should match(/1/)
    rendered.should match(/Url/)
  end
end
