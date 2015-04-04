class Testing
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :engineer
  belongs_to :examiner, class_name: "User", inverse_of: :examination_papers
  belongs_to :testing_paper

  has_many :testings_items_mappings

  field :testing_type, type: Integer, default: TestingPaper::TYPES[0]

  validates :testing_type, :engineer_id, :examiner_id, :testing_paper_id, presence: true

  attr_accessible :testing_type, :engineer_id, :examiner_id, :testing_paper_id

  scope :boarding, -> { where(testing_type: 0) }

  def pass?
    testings_items_mappings.map(&:pass).sum - testings_items_mappings.count == 0
  end

  def testing_items
    TestingItem.in(id: testings_items_mappings.pluck(:testing_item_id))
  end

  def type_str
    TestingPaper::TYPES_STR[testing_type]
  end

end
