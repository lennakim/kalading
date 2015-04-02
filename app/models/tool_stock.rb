class ToolStock
  include Mongoid::Document
  include Mongoid::Timestamps

  field :assigned_count, type: Integer, default: 0
  field :remained_count, type: Integer, default: 0
  field :tool_type_category, type: String

  attr_accessible :tool_type_id, :city_id

  belongs_to :tool_type
  belongs_to :city

  validates :assigned_count, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :remained_count, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates_presence_of :tool_type_id, :city_id
  validates_uniqueness_of :tool_type_id, scope: :city_id

  before_create :set_tool_type_category

  def set_tool_type_category
    self.tool_type_category = tool_type.category
  end
end
