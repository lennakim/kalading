require 'spec_helper'

describe "parts/edit" do
  before(:each) do
    @part = assign(:part, stub_model(Part,
      :number => "MyString",
      :stock_quantity => 1,
      :url => "MyString"
    ))
  end

  it "renders the edit part form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", part_path(@part), "post" do
      assert_select "input#part_number[name=?]", "part[number]"
      assert_select "input#part_stock_quantity[name=?]", "part[stock_quantity]"
      assert_select "input#part_url[name=?]", "part[url]"
    end
  end
end
