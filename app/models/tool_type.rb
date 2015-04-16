class ToolType
  include Mongoid::Document
  include Mongoid::Timestamps

  # 随人工具 随车工具
  CATEGORIES = %w[with_engineer with_vehicle]

  field :name, type: String
  field :spec, type: String
  field :category, type: String
  field :unit, type: String

  attr_accessible :name, :spec, :category, :unit

  validates :name, presence: true
  validates :category, inclusion: { in: CATEGORIES }

  scope :with_engineer, -> { where(category: 'with_engineer') }
  scope :with_vehicle, -> { where(category: 'with_vehicle') }

  def can_be_deleted?
    !ToolBatch.where(tool_type_id: self.id).exists?
  end

  def identification
    spec.present? ? "#{name} #{spec}" : name
  end
end
