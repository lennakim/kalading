require 'spec_helper'

describe "maintains/index" do
  before(:each) do
    assign(:maintains, [
      stub_model(Maintain,
        :outlook_desc => "Outlook Desc"
      ),
      stub_model(Maintain,
        :outlook_desc => "Outlook Desc"
      )
    ])
  end

  it "renders a list of maintains" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Outlook Desc".to_s, :count => 2
  end
end
