require 'spec_helper'

describe "part_brands/edit" do
  before(:each) do
    @part_brand = assign(:part_brand, stub_model(PartBrand,
      :name => "MyString"
    ))
  end

  it "renders the edit part_brand form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", part_brand_path(@part_brand), "post" do
      assert_select "input#part_brand_name[name=?]", "part_brand[name]"
    end
  end
end
