class TestingsItemsMapping
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :testing_item
  belongs_to :testing

  field :pass, type: Integer, default: 0 # 0 false, 1 true

  attr_accessible :testing_item_id, :testing_id, :pass
end
