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

  validates :name, presence: true, uniqueness: { scope: :spec }
  validates :category, inclusion: { in: CATEGORIES }

  scope :with_engineer, -> { where(category: 'with_engineer') }
  scope :with_vehicle, -> { where(category: 'with_vehicle') }
  scope :order_by_category_and_name, -> { order_by(:category.asc, :name.asc) }

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

  def self.category_human(category)
    I18n.t("simple_form.options.tool_type.category.#{category}")
  end

  def can_be_deleted?
    !ToolBatch.where(tool_type_id: self.id).exists?
  end

  def identification
    spec.present? ? "#{name} #{spec}" : name
  end

  def category_human
    self.class.category_human(category)
  end
end
