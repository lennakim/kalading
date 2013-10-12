require 'spec_helper'

describe "storehouses/new" do
  before(:each) do
    assign(:storehouse, stub_model(Storehouse,
      :name => "MyString",
      :address => "MyString",
      :phone_num => "MyString"
    ).as_new_record)
  end

  it "renders new storehouse form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", storehouses_path, "post" do
      assert_select "input#storehouse_name[name=?]", "storehouse[name]"
      assert_select "input#storehouse_address[name=?]", "storehouse[address]"
      assert_select "input#storehouse_phone_num[name=?]", "storehouse[phone_num]"
    end
  end
end
