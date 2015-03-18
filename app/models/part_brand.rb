# 配件品牌
class PartBrand
  include Mongoid::Document

  field :name, type: String
  # 配件品牌按照这个排序
  field :sort_factor, type: Integer, default: 0
  attr_accessible :name, :sort_factor
  
  has_many :parts, dependent: :destroy
 
  validates :name, uniqueness:  {case_sensitive: false}, presence: true
end
