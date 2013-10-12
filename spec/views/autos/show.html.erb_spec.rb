require 'spec_helper'

describe "autos/show" do
  before(:each) do
    @auto = assign(:auto, stub_model(Auto,
      :number => "Number",
      :vin => "Vin"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Number/)
    rendered.should match(/Vin/)
  end
end
