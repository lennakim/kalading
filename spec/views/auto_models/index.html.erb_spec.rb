require 'spec_helper'

describe "auto_models/index" do
  before(:each) do
    assign(:auto_models, [
      stub_model(AutoModel,
        :name => "Name"
      ),
      stub_model(AutoModel,
        :name => "Name"
      )
    ])
  end

  it "renders a list of auto_models" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
