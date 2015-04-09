require 'rails_helper'

RSpec.describe Engineer, :type => :model do

  it "should be type of User" do
    user = build(:engineer)
    user.class.should == Engineer
    user._type.should == "Engineer"
    user.should === User
  end

  it "should be role of engineer" do
    user = build :engineer
    user.should be_engineer
  end

  it "should generate right working tag number" do
    e1 = create(:engineer, email: '1@1.com' )
    e1.generate_working_tag_number

    year_mon = Time.now.strftime("%y%m")

    e1.work_tag_number.should == "#{year_mon}001"

    e2 = create(:engineer, email: '2@1.com', phone_num: "15512314123")
    e2.generate_working_tag_number

    e2.work_tag_number.should == "#{year_mon}002"
  end

  it "should have on boarding exam" do
    item_a = TestingItem.create content: "1111"
    item_b = TestingItem.create content: "2222"

    paper = TestingPaper.create title: 'test'
    paper.testing_items << item_a
    paper.testing_items << item_b

    e = create(:engineer)

    examiner = create(:engineer, email: 'examiner@kalading.com', phone_num: '15666666666')

    e.testings.create examiner_id: examiner.id, testing_paper_id: paper.id

    e.reload
    e.testings.first.examiner.should == examiner
  end

  it "should transform aasm state correctly if pass exam" do
    allow_any_instance_of(Engineer).to receive(:boarding_exam_pass?).and_return(true)

    e = create(:engineer)
    e.aasm_state.should == "training"

    e.exam!

    e.reload.aasm_state.should == "boarding"
  end

  it "should transform aasm state correctly if not pass exam" do
    allow_any_instance_of(Engineer).to receive(:boarding_exam_pass?).and_return(false)

    e = create(:engineer)
    e.aasm_state.should == "training"

    expect{
      e.exam
    }.to raise_error(AASM::InvalidTransition)
    e.reload.aasm_state.should == "training"

  end

  it "should transite from training to dimissory if not pass exam twice" do
    allow_any_instance_of(Engineer).to receive(:boarding_exam_pass?).and_return(false)
    allow_any_instance_of(Engineer).to receive(:can_take_boarding_exam?).and_return(false)
    e = create(:engineer)

    e.exam!
    e.reload.aasm_state.should == "dimissory"
  end


end
