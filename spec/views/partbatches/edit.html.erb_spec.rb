require 'spec_helper'

describe "partbatches/edit" do
  before(:each) do
    @partbatch = assign(:partbatch, stub_model(Partbatch,
      :number => 1,
      :price => ""
    ))
  end

  it "renders the edit partbatch form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", partbatch_path(@partbatch), "post" do
      assert_select "input#partbatch_number[name=?]", "partbatch[number]"
      assert_select "input#partbatch_price[name=?]", "partbatch[price]"
    end
  end
end
