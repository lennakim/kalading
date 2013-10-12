require 'spec_helper'

describe "service_types/edit" do
  before(:each) do
    @service_type = assign(:service_type, stub_model(ServiceType,
      :name => "MyString"
    ))
  end

  it "renders the edit service_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", service_type_path(@service_type), "post" do
      assert_select "input#service_type_name[name=?]", "service_type[name]"
    end
  end
end
