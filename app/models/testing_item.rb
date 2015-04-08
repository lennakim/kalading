class TestingItem
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :testings_items_mappings
  belongs_to :testing_paper

  field :content

  validates :content, presence: true
end
