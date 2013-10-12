require 'spec_helper'

describe "auto_models/new" do
  before(:each) do
    assign(:auto_model, stub_model(AutoModel,
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new auto_model form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", auto_models_path, "post" do
      assert_select "input#auto_model_name[name=?]", "auto_model[name]"
    end
  end
end
