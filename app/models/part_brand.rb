class PartBrand
  include Mongoid::Document

  field :name, type: String
  attr_accessible :name
  
  has_many :parts, dependent: :destroy
 
  validates :name, uniqueness:  {case_sensitive: false}, presence: true
end
