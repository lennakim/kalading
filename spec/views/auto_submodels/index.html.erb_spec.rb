require 'spec_helper'

describe "auto_submodels/index" do
  before(:each) do
    assign(:auto_submodels, [
      stub_model(AutoSubmodel,
        :name => "Name"
      ),
      stub_model(AutoSubmodel,
        :name => "Name"
      )
    ])
  end

  it "renders a list of auto_submodels" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
