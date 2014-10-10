require 'spec_helper'

describe "clients/edit" do
  before(:each) do
    @client = assign(:client, stub_model(Client,
      :phone_num => "MyString",
      :balance => 1
    ))
  end

  it "renders the edit client form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", client_path(@client), "post" do
      assert_select "input#client_phone_num[name=?]", "client[phone_num]"
      assert_select "input#client_balance[name=?]", "client[balance]"
    end
  end
end
