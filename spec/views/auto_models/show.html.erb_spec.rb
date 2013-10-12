require 'spec_helper'

describe "auto_models/show" do
  before(:each) do
    @auto_model = assign(:auto_model, stub_model(AutoModel,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
  end
end
