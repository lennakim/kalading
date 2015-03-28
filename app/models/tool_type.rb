class ToolType
  include Mongoid::Document
  include Mongoid::Timestamps

  # 随人工具 随车工具
  CATEGORIES = %w[with_engineer with_vehicle]

  field :name, type: String
  field :category, type: String
  field :unit, type: String

  attr_accessible :name, :category, :unit

  validates :name, presence: true
  validates :category, inclusion: { in: CATEGORIES }

  scope :with_engineer, -> { where(category: 'with_engineer') }
  scope :with_vehicle, -> { where(category: 'with_vehicle') }

  def self.with_assignee(assignee)
    case assignee.model_name
    when 'Engineer'
      with_engineer
    when 'ServiceVehicle'
      with_vehicle
    else
      self
    end
  end
end
