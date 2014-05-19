require 'spec_helper'

describe "maintains/edit" do
  before(:each) do
    @maintain = assign(:maintain, stub_model(Maintain,
      :outlook_desc => "MyString"
    ))
  end

  it "renders the edit maintain form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", maintain_path(@maintain), "post" do
      assert_select "input#maintain_outlook_desc[name=?]", "maintain[outlook_desc]"
    end
  end
end
