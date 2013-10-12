require 'spec_helper'

describe "autos/new" do
  before(:each) do
    assign(:auto, stub_model(Auto,
      :number => "MyString",
      :vin => "MyString"
    ).as_new_record)
  end

  it "renders new auto form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", autos_path, "post" do
      assert_select "input#auto_number[name=?]", "auto[number]"
      assert_select "input#auto_vin[name=?]", "auto[vin]"
    end
  end
end
