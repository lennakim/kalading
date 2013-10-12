require 'spec_helper'

describe "storehouses/show" do
  before(:each) do
    @storehouse = assign(:storehouse, stub_model(Storehouse,
      :name => "Name",
      :address => "Address",
      :phone_num => "Phone Num"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Address/)
    rendered.should match(/Phone Num/)
  end
end
