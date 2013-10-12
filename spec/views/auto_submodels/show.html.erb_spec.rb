require 'spec_helper'

describe "auto_submodels/show" do
  before(:each) do
    @auto_submodel = assign(:auto_submodel, stub_model(AutoSubmodel,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
  end
end
