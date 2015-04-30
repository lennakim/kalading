class ToolSupplier
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  attr_accessible :name

  validates :name, presence: true

  scope :order_by_name, -> { order_by(:name.asc) }

  def can_be_deleted?
    !ToolDetail.where(tool_supplier_id: id).exists?
  end
end
