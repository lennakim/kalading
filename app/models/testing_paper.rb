class TestingPaper
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :testings
  has_many :testing_items

  field :title

  TYPES = [0]
  TYPES_STR = %w-入职考试-
  field :testing_type, type: Integer, default: TYPES[0]

  validates :title, :testing_type, presence: true

  attr_accessible :testing_type, :title

  def boarding_test?
    testing_type == 0
  end

  def type_str
    TYPES_STR[testing_type]
  end

end
