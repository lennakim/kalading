class Storehouse
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, type: String
  field :address, type: String
  field :phone_num, type: String
  
  attr_accessible :name, :address, :phone_num, :partbatch_ids, :partbatches_attributes
  

  has_many :partbatches
  accepts_nested_attributes_for :partbatches, :allow_destroy => true
end
