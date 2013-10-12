require 'spec_helper'

describe "auto_brands/new" do
  before(:each) do
    assign(:auto_brand, stub_model(AutoBrand,
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new auto_brand form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", auto_brands_path, "post" do
      assert_select "input#auto_brand_name[name=?]", "auto_brand[name]"
    end
  end
end
