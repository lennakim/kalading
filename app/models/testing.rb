class Testing
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :engineer
  belongs_to :examiner, class_name: "Engineer", inverse_of: :examination_papers

  # 理论 、 实操 (通过、不通过）

  # has_one :testing_paper
end
