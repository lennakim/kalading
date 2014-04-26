class Supplier
  include Mongoid::Document
  
  field :name, type: String
  field :address, type: String
  field :phone_num, type: String
  
  attr_accessible :name, :address, :phone_num
  
  has_many :partbatches
end
