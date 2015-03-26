class ToolBatch
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer
  field :price, type: Money
  # 批次/规格
  field :spec, type: String
  field :note, type: String

  attr_accessible :quantity, :price, :spec, :note, :tool_type_id, :city_id

  belongs_to :tool_type
  belongs_to :city
  belongs_to :operator, class_name: 'User'
  belongs_to :tool_stock

  validates :quantity, numericality: { greater_than: 0, less_than: 100_000, only_integer: true }
  validates :price, numericality: { greater_than: 0 }
  validates_presence_of :tool_type_id, :city_id, :operator_id

  before_create :increase_tool_stock

  def increase_tool_stock
    conditions = { city_id: city.id, tool_type_id: tool_type.id }
    tool_stock = ToolStock.where(conditions).first || ToolStock.create!(conditions)
    tool_stock.inc(:remained_count, self.quantity)
    self.tool_stock = tool_stock
  end
end
