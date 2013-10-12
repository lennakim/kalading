class SellPrice
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :price, type: Money
  attr_accessible :price, :part_id, :service_type_id
  belongs_to :part
  belongs_to :service_type
end
