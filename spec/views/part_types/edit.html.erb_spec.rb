require 'spec_helper'

describe "part_types/edit" do
  before(:each) do
    @part_type = assign(:part_type, stub_model(PartType,
      :name => "MyString"
    ))
  end

  it "renders the edit part_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", part_type_path(@part_type), "post" do
      assert_select "input#part_type_name[name=?]", "part_type[name]"
    end
  end
end
