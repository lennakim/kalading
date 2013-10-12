class PartItem
  include Mongoid::Document
  field :quantity, type: Integer
  
  embedded_in :order
  belongs_to :part

  attr_accessible :quantity, :order_id, :part_id
  validates :part_id, presence: true
  validates :quantity, inclusion: { in: 1..999999 }, presence: true
  
  
end
