require 'spec_helper'

describe "maintains/show" do
  before(:each) do
    @maintain = assign(:maintain, stub_model(Maintain,
      :outlook_desc => "Outlook Desc"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Outlook Desc/)
  end
end
