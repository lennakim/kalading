class ServiceItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :price, type: Money
  
  belongs_to :service_type
  belongs_to :order
  attr_accessible :price, :service_type_id, :order_id, :service_type
  
  validates :service_type_id, presence: true
  validates :order_id, presence: true
end
