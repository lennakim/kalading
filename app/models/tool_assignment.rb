class ToolAssignment
  include Mongoid::Document
  include Mongoid::Timestamps

  # 使用中 损坏 丢失
  STATUSES = %w[normal broken lost]

  field :status, type: String, default: 'normal'
  # 是否损坏/丢失
  field :discarded, type: Boolean, default: false
  # 将工具标记为损坏或丢失的时间
  field :applied_at, type: DateTime
  # 批准损坏/丢失申请的时间
  field :approved_at, type: DateTime
  field :tool_type_category, type: String

  attr_accessible :city_id, :tool_type_id, :assigner_id

  belongs_to :city
  belongs_to :tool_type
  # 分配工具的操作者
  belongs_to :assigner, class_name: 'User'
  # 分到工具的技师或车
  belongs_to :assignee, polymorphic: true
  # 将工具标记为损坏或丢失的技师
  belongs_to :applicant, class_name: 'User'
  # 批准损坏/丢失申请的操作者
  belongs_to :approver, class_name: 'User'

  validates :status, inclusion: { in: STATUSES }
  validates_presence_of :city_id, :tool_type_id, :assigner_id, :assignee_id, :assignee_type

  before_create :set_tool_type_category
  after_create :increase_assignments_count

  # 已分配，且没有被标记为损坏或丢失的
  scope :normal, -> { where(discarded: false) }
  # 已分配的，包括被标记为损坏或丢失且没有被重新分配的
  scope :current, -> { where(approved_at: nil) }
  # 已被标记为损坏或丢失，还没有被重新分配的
  scope :discarding, -> { where(discarded: true, approved_at: nil) }

  def set_tool_type_category
    self.tool_type_category = tool_type.category
  end

  def increase_assignments_count
    assignee.inc(:current_tool_assignments_count, 1)
  end

  def mark_as_broken(applicant)
    return false if discarded?

    self.status = 'broken'
    mark_as_discarded(applicant)
  end

  def mark_as_lost(applicant)
    return false if discarded?

    self.status = 'lost'
    mark_as_discarded(applicant)
  end

  def approve_discarded(approver)
    self.approved_at = Time.current
    self.approver = approver
    self.save && modify_assignments_counts_after_approving
  end

  private

    def mark_as_discarded(applicant)
      self.discarded = true
      self.applied_at = Time.current
      self.applicant = applicant
      self.save && !!assignee.inc(:discarded_assignments_count, 1)
    end

    def modify_assignments_counts_after_approving
      assignee.current_tool_assignments_count -= 1
      assignee.discarded_assignments_count -= 1
      assignee.save(validate: false)
    end
end
