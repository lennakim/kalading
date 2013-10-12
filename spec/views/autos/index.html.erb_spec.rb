require 'spec_helper'

describe "autos/index" do
  before(:each) do
    assign(:autos, [
      stub_model(Auto,
        :number => "Number",
        :vin => "Vin"
      ),
      stub_model(Auto,
        :number => "Number",
        :vin => "Vin"
      )
    ])
  end

  it "renders a list of autos" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Number".to_s, :count => 2
    assert_select "tr>td", :text => "Vin".to_s, :count => 2
  end
end
