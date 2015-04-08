class ToolDetail
  include Mongoid::Document
  include Mongoid::Timestamps

  # 使用寿命
  field :lifetime, type: Integer
  # 保修期
  field :warranty_period, type: Integer
  field :price, type: Money

  attr_accessible :lifetime, :warranty_period, :price, :tool_type_id, :tool_brand_id, :tool_supplier_id

  belongs_to :tool_type
  belongs_to :tool_brand
  belongs_to :tool_supplier

  validates :lifetime, numericality: { greater_than: 0, less_than: 10*12, only_integer: true }
  validates :warranty_period, numericality: { greater_than: 0, less_than: 10*12, only_integer: true }
  validates :price, numericality: { greater_than: 0 }
  validates_presence_of :tool_type_id, :tool_brand_id, :tool_supplier_id
  validates_uniqueness_of :tool_type_id, scope: [:tool_brand_id, :tool_supplier_id]

  def can_be_deleted?
    # TODO: 需实现
    true
  end

  def existed_siblings_by_tool_type
    if tool_type_id.present?
      self.class.where(tool_type_id: tool_type_id).all
    end
  end
end
