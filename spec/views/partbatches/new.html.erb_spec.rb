require 'spec_helper'

describe "partbatches/new" do
  before(:each) do
    assign(:partbatch, stub_model(Partbatch,
      :number => 1,
      :price => ""
    ).as_new_record)
  end

  it "renders new partbatch form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", partbatches_path, "post" do
      assert_select "input#partbatch_number[name=?]", "partbatch[number]"
      assert_select "input#partbatch_price[name=?]", "partbatch[price]"
    end
  end
end
