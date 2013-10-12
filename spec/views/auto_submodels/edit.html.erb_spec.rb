require 'spec_helper'

describe "auto_submodels/edit" do
  before(:each) do
    @auto_submodel = assign(:auto_submodel, stub_model(AutoSubmodel,
      :name => "MyString"
    ))
  end

  it "renders the edit auto_submodel form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", auto_submodel_path(@auto_submodel), "post" do
      assert_select "input#auto_submodel_name[name=?]", "auto_submodel[name]"
    end
  end
end
