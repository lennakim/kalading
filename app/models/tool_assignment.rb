class ToolAssignment
  include Mongoid::Document
  include Mongoid::Timestamps

  # 使用中 损坏 丢失
  STATUSES = %w[normal broken lost]

  field :status, type: String, default: 'normal'
  # 是否丢失/损坏
  field :discarded, type: Boolean, default: false
  # 将工具标记为损坏或丢失的时间
  field :applied_at, type: DateTime
  # 批准丢失/损坏申请的时间
  field :approved_at, type: DateTime

  # 已分配工具页面使用
  index({ assignee_id: 1, tool_suite_assignment_id: 1, approved_at: 1, created_at: -1 })
  index({ assignee_id: 1, created_at: -1 })

  # 关联查询使用
  index({ tool_suite_assignment_id: 1 })

  # 丢失/损坏页面使用
  index({ discarded: 1, approved_at: 1, applied_at: 1 })
  index({ city_id: 1, discarded: 1, approved_at: 1, applied_at: 1 })
  index({ city_id: 1, approved_at: -1 })
  index({ approved_at: -1 })

  attr_accessible :tool_type_id, :tool_brand_id, :batch_quantity, :batch_tool_numbers
  # is_batch_primary为true的话，表示这条记录对应页面上的一条工具分配信息
  # 与之对应的是sibling_assignments，表示根据primary自动创建的分配
  # 比如primary的batch_quantity是3，则会自动再创建2个sibling_assignments
  attr_accessor :is_batch_primary, :batch_quantity, :batch_tool_numbers, :tool_ids, :tool_numbers

  belongs_to :tool
  belongs_to :city
  belongs_to :tool_type
  belongs_to :tool_brand
  # 分配工具的操作者
  belongs_to :assigner, class_name: 'User'
  # 分到工具的技师或车
  belongs_to :assignee, polymorphic: true
  # 将工具标记为损坏或丢失的技师
  belongs_to :applicant, class_name: 'User'
  # 批准丢失/损坏申请的操作者
  belongs_to :approver, class_name: 'User'
  # 按套分配，则tool_suite_assignment_id不为空
  belongs_to :tool_suite_assignment

  validates :status, inclusion: { in: STATUSES }
  validates_presence_of :city_id, :tool_type_id, :tool_brand_id, :assigner_id, :assignee_id, :assignee_type
  validates :batch_quantity, numericality: { greater_than: 0, only_integer: true }, on: :create, if: :is_batch_primary
  validate :check_tool_type_category, on: :create
  validate :validate_batch_tool_numbers, on: :create, if: :is_batch_primary
  validate :check_stock_and_set_tool_ids, on: :create, if: :is_batch_primary
  # 这个validation必须放在check_stock_and_set_tool_ids之后
  validates_presence_of :tool_id

  before_validation :set_city, on: :create

  # 已分配，且没有被标记为损坏或丢失的
  scope :normal, -> { where(discarded: false) }
  # 已分配的，包括被标记为损坏或丢失且没有被批准的
  scope :owned, -> { where(approved_at: nil) }
  # 已被标记为损坏或丢失，还没有被批准的
  scope :discarding, -> { where(discarded: true, approved_at: nil) }
  # 损坏或丢失，且已经被批准的
  scope :approved, -> { where(:approved_at.ne => nil) }

  def self.batch_assign(attrs, assignee, assigner)
    assignments = attrs.map do |attr|
      assignment = new(attr)
      assignment.is_batch_primary = true
      assignment.assignee = assignee
      assignment.assigner = assigner
      assignment
    end

    if !check_duplication(assignments)
      return assignments, 0
    end

    all_valid = assignments.inject(true) { |r, a| a.valid? && r }
    # 确保所有新建的assignment都是valid，再一次性都保存
    if all_valid
      saved_count = assignments.sum(&:assign)
    else
      saved_count = 0
    end

    assignee.organize_tools_by_suite

    return assignments, saved_count
  end

  def self.check_duplication(assignments)
    duplicate_result = {}
    assignments.each do |assign|
      next if assign.tool_type_id.blank? || assign.tool_brand_id.blank?

      uniq_key = "#{assign.tool_type_id}-#{assign.tool_brand_id}"
      duplicate_result[uniq_key] ||= []
      duplicate_result[uniq_key] << assign
    end

    duplicate_result.each_value do |v|
      v.each { |assign| assign.errors.add(:tool_type_id, :taken) } if v.size > 1
    end

    assignments.all? { |assign| assign.errors.empty? }
  end

  def check_tool_type_category
    if (assignee_type == 'Engineer' && tool_type.category == 'with_vehicle') ||
      (assignee_type == 'ServiceVehicle' && tool_type.category == 'with_engineer')
      errors.add(:tool_type_id, :invalid_tool_type_category,
                 category: tool_type.category_human,
                 assignee_type: assignee.model_name.human)
    end
  end

  def validate_batch_tool_numbers
    if batch_tool_numbers.present? && !errors.has_key?(:batch_quantity)
      self.tool_numbers = batch_tool_numbers.split(/,|，/).reject { |n| n.blank? }
      if tool_numbers.size != batch_quantity.to_i
        errors.add(:batch_tool_numbers, :match)
      end
    end
  end

  def set_city
    self.city_id = assignee.try(:city_id)
  end

  def check_stock_and_set_tool_ids
    return if city_id.blank? || tool_type_id.blank? || tool_brand_id.blank? || errors.has_key?(:batch_quantity)

    _batch_quantity = batch_quantity.to_i
    _tool_ids = Tool.stock.individual
                          .where(city_id: city_id,
                                 tool_type_id: tool_type_id,
                                 tool_brand_id: tool_brand_id)
                          .limit(_batch_quantity)
                          .pluck(:id)

    if _tool_ids.size < _batch_quantity
      errors.add(:batch_quantity, :more_than_stock, count: _tool_ids.size)
    else
      self.tool_id = _tool_ids.shift
      self.tool_ids = _tool_ids
    end
  end

  def assign
    saved_count = 0
    self.tool_numbers = Array.wrap(tool_numbers)

    if save && tool.mark_as_assigned(tool_numbers.shift)
      saved_count += 1
      saved_count += assign_siblings(tool_ids, tool_numbers)
    end

    saved_count
  end

  def assign_siblings(tool_ids, tool_numbers)
    tool_ids.sum do |_tool_id|
      sibling = copy_to_sibling
      sibling.tool_id = _tool_id
      if sibling.save && sibling.tool.mark_as_assigned(tool_numbers.shift)
        1
      else
        0
      end
    end
  end

  def copy_to_sibling
    sibling = self.class.new
    %w[tool_type_id tool_brand_id assigner assignee].each do |attr|
      # sibling.tool_type_id = self.tool_type_id
      sibling.send("#{attr}=", self.send(attr))
    end
    sibling
  end

  def mark_as_broken(applicant)
    return false if discarded?

    self.status = 'broken'
    if mark_as_discarded(applicant)
      assignee.organize_tools_by_suite
      true
    end
  end

  def mark_as_lost(applicant)
    return false if discarded?

    self.status = 'lost'
    if mark_as_discarded(applicant)
      assignee.organize_tools_by_suite
      true
    end
  end

  def approved?
    approved_at.present?
  end

  def approve_discarded(approver)
    return if approved?

    self.approved_at = Time.current
    self.approver = approver
    self.save
  end

  def add_to_suite(suite_assignment)
    self.update_attribute(:tool_suite_assignment_id, suite_assignment.id)
    suite_assignment.tool_suite_inventory.tools << self.tool
  end

  private

    def mark_as_discarded(applicant)
      self.discarded = true
      # 报损后就把该工具从套装中剔除
      self.tool_suite_assignment_id = nil
      self.applied_at = Time.current
      self.applicant = applicant
      self.save && tool.mark_as_discarded
    end
end
