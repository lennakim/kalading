class ToolBrand
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  attr_accessible :name

  validates :name, presence: true

  def can_be_deleted?
    !ToolDetail.where(tool_brand_id: id).exists?
  end
end
