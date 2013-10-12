require 'spec_helper'

describe "storehouses/edit" do
  before(:each) do
    @storehouse = assign(:storehouse, stub_model(Storehouse,
      :name => "MyString",
      :address => "MyString",
      :phone_num => "MyString"
    ))
  end

  it "renders the edit storehouse form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", storehouse_path(@storehouse), "post" do
      assert_select "input#storehouse_name[name=?]", "storehouse[name]"
      assert_select "input#storehouse_address[name=?]", "storehouse[address]"
      assert_select "input#storehouse_phone_num[name=?]", "storehouse[phone_num]"
    end
  end
end
