require 'spec_helper'

describe "auto_models/edit" do
  before(:each) do
    @auto_model = assign(:auto_model, stub_model(AutoModel,
      :name => "MyString"
    ))
  end

  it "renders the edit auto_model form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", auto_model_path(@auto_model), "post" do
      assert_select "input#auto_model_name[name=?]", "auto_model[name]"
    end
  end
end
