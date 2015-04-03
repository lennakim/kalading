class TestingsItemsMapping
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :testing_items
  belongs_to :testing_paper
end
