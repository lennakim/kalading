require 'spec_helper'

describe "maintains/new" do
  before(:each) do
    assign(:maintain, stub_model(Maintain,
      :outlook_desc => "MyString"
    ).as_new_record)
  end

  it "renders new maintain form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", maintains_path, "post" do
      assert_select "input#maintain_outlook_desc[name=?]", "maintain[outlook_desc]"
    end
  end
end
