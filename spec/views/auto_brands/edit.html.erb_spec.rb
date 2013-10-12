require 'spec_helper'

describe "auto_brands/edit" do
  before(:each) do
    @auto_brand = assign(:auto_brand, stub_model(AutoBrand,
      :name => "MyString"
    ))
  end

  it "renders the edit auto_brand form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", auto_brand_path(@auto_brand), "post" do
      assert_select "input#auto_brand_name[name=?]", "auto_brand[name]"
    end
  end
end
