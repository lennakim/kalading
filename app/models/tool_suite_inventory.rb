# 成套的工具，包括库存的、调货的、已分配的
class ToolSuiteInventory
  include Mongoid::Document
  include Mongoid::Timestamps

  STATUSES = %w[stock delivering assigned]
  # whole: 全部套内工具都齐全
  # core: 必需的工具齐全，其他工具不一定全
  # incomplete: 必需的工具不齐全
  COMPLETENESS = %w[whole core incomplete]

  field :status, type: String, default: 'stock'
  field :completeness, type: String
  field :tool_type_category, type: String

  belongs_to :city
  belongs_to :tool_delivery
  belongs_to :tool_suite
  has_many :tools, dependent: :nullify

  validates :status, inclusion: { in: STATUSES }
  validates :completeness, inclusion: { in: COMPLETENESS }
  validates_presence_of :tool_suite_id, :tool_type_category, :city_id

  before_validation :set_attrs_by_tool_suite

  scope :stock, -> { where(status: 'stock') }
  scope :whole, -> { where(completeness: 'whole') }

  def self.organize_all
    beijing = City.beijing
    ToolSuite.all.to_a.each { |suite| organize(suite, beijing) }
  end

  # 把零散的工具整编成套
  def self.organize(suite, city)
    requirement = suite.whole_requirement

    grouped_tools = Tool.individual.stock
                                   .where(tool_type_category: suite.tool_type_category)
                                   .where(city_id: city.id)
                                   .only(:tool_type_id)
                                   .all
                                   .group_by(&:tool_type_id)
    grouped_tools.each { |k, v| grouped_tools[k] = v.map(&:id) }

    return if grouped_tools.size < requirement.size

    catch :done do
      while true do
        _tool_ids = []
        requirement.each do |tool_type_id, quantity|
          ids = grouped_tools[tool_type_id].slice!(0, quantity) if grouped_tools[tool_type_id].present?
          ids = Array.wrap(ids)
          throw :done if ids.size < quantity
          _tool_ids.concat(ids)
        end

        new_inventory = self.new
        new_inventory.city = city
        new_inventory.completeness = 'whole'
        new_inventory.tool_suite = suite
        new_inventory.save!
        new_inventory.tool_ids = _tool_ids
      end
    end
  end

  def self.statistics_summary
    statistics_statuses = %w[stock delivering assigned]

    match = {
      status: {'$in' => statistics_statuses},
      completeness: {'$in' => %w[whole core]}
    }

    project = {
      city_id: 1,
      status: 1,
      tool_type_category: 1
    }

    group = {
      _id: {city_id: '$city_id'},
      total: {'$sum' => 1}
    }

    ToolType::CATEGORIES.product(statistics_statuses).each do |category, status|
      identification = "#{category}_#{status}"
      group[identification] = {
        '$sum' => {
          '$cond' => [{
              '$and' => [
                {'$eq' => ['$tool_type_category', category]},
                {'$eq' => ['$status', status]}
              ]
            }, 1, 0]
        }
      }
    end

    collection.aggregate(
      { '$match' => match },
      { '$project' => project },
      { '$group' => group }
    )
  end

  def self.set_statistics_summary_total(statistics_result)
    total = {}
    statistics_statuses = %w[stock delivering assigned]

    ToolType::CATEGORIES.product(statistics_statuses).each do |item|
      identification = item.join('_')
      total[identification] = statistics_result.sum(&:"#{identification}")
    end

    ToolType::CATEGORIES.each do |category|
      total[category] = statistics_statuses.map {|status| total["#{category}_#{status}"].to_i}.sum
    end

    total
  end

  def set_attrs_by_tool_suite
    self.tool_type_category = tool_suite.tool_type_category
  end
end
