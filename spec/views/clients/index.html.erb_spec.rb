require 'spec_helper'

describe "clients/index" do
  before(:each) do
    assign(:clients, [
      stub_model(Client,
        :phone_num => "Phone Num",
        :balance => 1
      ),
      stub_model(Client,
        :phone_num => "Phone Num",
        :balance => 1
      )
    ])
  end

  it "renders a list of clients" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Phone Num".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
