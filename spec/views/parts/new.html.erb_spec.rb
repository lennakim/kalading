require 'spec_helper'

describe "parts/new" do
  before(:each) do
    assign(:part, stub_model(Part,
      :number => "MyString",
      :stock_quantity => 1,
      :url => "MyString"
    ).as_new_record)
  end

  it "renders new part form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", parts_path, "post" do
      assert_select "input#part_number[name=?]", "part[number]"
      assert_select "input#part_stock_quantity[name=?]", "part[stock_quantity]"
      assert_select "input#part_url[name=?]", "part[url]"
    end
  end
end
