require 'spec_helper'

describe "part_brands/new" do
  before(:each) do
    assign(:part_brand, stub_model(PartBrand,
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new part_brand form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", part_brands_path, "post" do
      assert_select "input#part_brand_name[name=?]", "part_brand[name]"
    end
  end
end
