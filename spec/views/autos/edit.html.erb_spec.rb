require 'spec_helper'

describe "autos/edit" do
  before(:each) do
    @auto = assign(:auto, stub_model(Auto,
      :number => "MyString",
      :vin => "MyString"
    ))
  end

  it "renders the edit auto form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", auto_path(@auto), "post" do
      assert_select "input#auto_number[name=?]", "auto[number]"
      assert_select "input#auto_vin[name=?]", "auto[vin]"
    end
  end
end
