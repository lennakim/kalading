class MotoroilGroup
  include Mongoid::Document
  field :name, type: String
  field :parts_order, type: Hash, default: {}
  
  validates :name, uniqueness:  {case_sensitive: false}, presence: true
  
  has_many :auto_submodels
  has_and_belongs_to_many :parts
  
  accepts_nested_attributes_for :parts
  
  attr_accessible :name, :auto_submodel_ids, :part_ids, :parts_order
  
  def ordered_parts
    self.parts.sort_by {|p| self.parts_order[p.id.to_s] }
  end
end
