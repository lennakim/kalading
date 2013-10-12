require 'spec_helper'

describe "partbatches/show" do
  before(:each) do
    @partbatch = assign(:partbatch, stub_model(Partbatch,
      :number => 1,
      :price => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(//)
  end
end
