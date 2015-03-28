class ToolAssignment
  include Mongoid::Document
  include Mongoid::Timestamps

  # 使用中 损坏 丢失
  STATUSES = %[normal broken lost]

  field :status, type: String, default: 'normal'
  # 是否损坏/丢失
  field :discarded, type: Boolean, default: false
  # 将工具标记为损坏或丢失的时间
  field :applied_at, type: DateTime
  # 批准损坏/丢失申请的时间
  field :approved_at, type: DateTime

  attr_accessible :city_id, :tool_type_id, :assigner_id

  belongs_to :city
  belongs_to :tool_type
  # 分配工具的操作者
  belongs_to :assigner, class_name: 'User'
  # 分到工具的技师或车
  belongs_to :assignee, polymorphic: true, counter_cache: true, inverse_of: :tool_assignments
  # 将工具标记为损坏或丢失的技师
  belongs_to :applicant, class_name: 'User'
  # 批准损坏/丢失申请的操作者
  belongs_to :approver, class_name: 'User'

  validates :status, inclusion: { in: STATUSES }
  validates_presence_of :city_id, :tool_type_id, :assigner_id, :assignee_id, :assignee_type

  before_create :decrease_tool_stock

  def decrease_tool_stock
    tool_stock = ToolStock.where(city_id: city.id, tool_type_id: tool_type.id).first_or_create!
    tool_stock.assigned_count += 1
    tool_stock.remained_count -= 1
    return false if !tool_stock.save
  end
end
