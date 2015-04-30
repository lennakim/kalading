class ToolSuiteAssignment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :tool_type_category, type: String

  index({ assignee_id: 1 })

  attr_accessible :tool_suite_id

  belongs_to :city
  belongs_to :tool_suite
  # 分配工具的操作者
  belongs_to :assigner, class_name: 'User'
  # 分到工具的技师或车
  belongs_to :assignee, polymorphic: true
  belongs_to :tool_suite_inventory
  has_many :tool_assignments

  validates :tool_suite_id, presence: true, uniqueness: { scope: [:assignee_id, :assignee_type] }
  validates_presence_of :city_id, :tool_type_category
  validate :check_and_set_tool_suite_inventory, on: :create
  validate :check_tool_type_category, on: :create

  before_validation :set_city, :set_tool_type_category, on: :create
  after_create :set_tools_for_assigning

  def set_city
    self.city_id = assignee.try(:city_id)
  end

  def set_tool_type_category
    self.tool_type_category = tool_suite.try(:tool_type_category)
  end

  def check_and_set_tool_suite_inventory
    return if city_id.blank? || tool_suite_id.blank?

    inventory = ToolSuiteInventory.stock.where(city_id: city_id, tool_suite_id: tool_suite_id).first
    if inventory.blank?
      errors.add(:tool_suite_id, :more_than_stock)
    else
      self.tool_suite_inventory = inventory
    end
  end

  def check_tool_type_category
    if (assignee_type == 'Engineer' && tool_suite.tool_type_category == 'with_vehicle') ||
      (assignee_type == 'ServiceVehicle' && tool_suite.tool_type_category == 'with_engineer')
      errors.add(:tool_suite_id, :invalid_tool_type_category,
                 suite: tool_suite.name,
                 assignee_type: assignee.model_name.human)
    end
  end

  def assign(assignee, assigner, options = {})
    self.assignee = assignee
    self.assigner = assigner
    if options[:validate] == false
      save(validate: false)
    else
      save
    end
  end

  def set_tools_for_assigning
    tool_suite_inventory.update_attribute(:status, 'assigned')

    tool_suite_inventory.tools.each do |tool|
      assign = ToolAssignment.new
      assign.tool = tool
      assign.tool_type = tool.tool_type
      assign.tool_brand = tool.tool_brand
      assign.assignee = self.assignee
      assign.assigner = self.assigner
      assign.tool_suite_assignment = self
      assign.save && tool.mark_as_assigned
    end
  end
end
