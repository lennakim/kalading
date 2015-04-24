class ToolSuite
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :tool_type_category, type: String

  attr_accessible :name, :tool_type_category, :tool_suite_items_attributes

  has_many :tool_suite_items
  accepts_nested_attributes_for :tool_suite_items, allow_destroy: true

  validates :name, presence: true, uniqueness: { scope: :tool_type_category }
  validates :tool_type_category, inclusion: { in: ToolType::CATEGORIES }
  validates_presence_of :tool_suite_items
  # 不能用validate，因为error是加在item上的，用validate的话tool_suite.valid?仍然返回true，进而save
  before_save :check_tool_type_category, :check_duplicated_items

  # 不能放到tool_suite_item里去，item.tool_suite.object_id != tool_suite.object_id
  # 如果tool_suite.tool_type_category的值改变了的话，在item里是无法获取到的
  def check_tool_type_category
    all_valid = true

    tool_suite_items.each do |item|
      next if item.tool_type_id.blank?

      if tool_type_category != item.tool_type.category
        all_valid = false
        item.errors.add(:tool_type, :illegal_category, category: ToolType.category_human(tool_type_category))
      end
    end

    all_valid
  end

  def check_duplicated_items
    result = {}
    tool_suite_items.each do |item|
      uniq_key = item.tool_type_id
      next if uniq_key.blank?

      result[uniq_key] ||= []
      result[uniq_key] << item
    end

    all_valid = true
    result.each_value do |v|
      if v.size > 1
        all_valid = false
        v.each { |item| item.errors.add(:tool_type, :taken) }
      end
    end

    all_valid
  end

  # TODO
  def can_be_deleted?
    true
  end
end
