class TestingItem
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :testings_items_mappings
  has_many :testings, through: :testings_items_mappings
end
