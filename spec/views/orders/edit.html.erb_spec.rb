require 'spec_helper'

describe "orders/edit" do
  before(:each) do
    @order = assign(:order, stub_model(Order,
      :state => "MyString",
      :address => "MyString",
      :phone_num => "MyString",
      :buymyself => false
    ))
  end

  it "renders the edit order form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", order_path(@order), "post" do
      assert_select "input#order_state[name=?]", "order[state]"
      assert_select "input#order_address[name=?]", "order[address]"
      assert_select "input#order_phone_num[name=?]", "order[phone_num]"
      assert_select "input#order_buymyself[name=?]", "order[buymyself]"
    end
  end
end
