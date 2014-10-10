require 'spec_helper'

describe "clients/new" do
  before(:each) do
    assign(:client, stub_model(Client,
      :phone_num => "MyString",
      :balance => 1
    ).as_new_record)
  end

  it "renders new client form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", clients_path, "post" do
      assert_select "input#client_phone_num[name=?]", "client[phone_num]"
      assert_select "input#client_balance[name=?]", "client[balance]"
    end
  end
end
