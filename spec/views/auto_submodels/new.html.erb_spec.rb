require 'spec_helper'

describe "auto_submodels/new" do
  before(:each) do
    assign(:auto_submodel, stub_model(AutoSubmodel,
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new auto_submodel form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", auto_submodels_path, "post" do
      assert_select "input#auto_submodel_name[name=?]", "auto_submodel[name]"
    end
  end
end
