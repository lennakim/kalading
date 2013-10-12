require 'spec_helper'

describe "partbatches/index" do
  before(:each) do
    assign(:partbatches, [
      stub_model(Partbatch,
        :number => 1,
        :price => ""
      ),
      stub_model(Partbatch,
        :number => 1,
        :price => ""
      )
    ])
  end

  it "renders a list of partbatches" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
