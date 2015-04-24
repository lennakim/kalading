class ToolSuiteItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer
  field :required, type: Boolean

  attr_accessible :quantity, :required, :tool_type_id

  belongs_to :tool_suite
  belongs_to :tool_type

  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates_presence_of :required, :tool_suite_id, :tool_type_id
end
