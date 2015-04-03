class Testing
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :engineer
  belongs_to :examiner, class_name: "Engineer", inverse_of: :examination_papers

  # 理论 、 实操 (通过、不通过）

  has_many :testings_items_mappings
  has_many :testing_items, through: :testings_items_mappings
end
