require 'rails_helper'

RSpec.describe TestingPaper, :type => :model do

  before(:each) do
    item_a = TestingItem.create content: "1111"
    item_b = TestingItem.create content: "2222"

    @paper = TestingPaper.create

    @paper.add_items item_a
    @paper.add_items item_b
  end

  it "should have testing paper with correct items" do
    @paper.should_not be_nil
    @paper.testing_items.count.should == 2
  end


end
