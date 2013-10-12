require 'spec_helper'

describe "orders/show" do
  before(:each) do
    @order = assign(:order, stub_model(Order,
      :state => "State",
      :address => "Address",
      :phone_num => "Phone Num",
      :buymyself => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/State/)
    rendered.should match(/Address/)
    rendered.should match(/Phone Num/)
    rendered.should match(/false/)
  end
end
