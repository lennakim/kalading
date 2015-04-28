# 零散工具调货信息的一条明细
class ToolDeliveryItem
  include Mongoid::Document

  # 发货数
  field :quantity, type: Integer
  # 实际收货数
  field :received_quantity, type: Integer
  field :tool_ids, type: Array, default: []
  field :received_tool_ids, type: Array, default: []

  attr_accessible :quantity, :tool_type_id, :tool_brand_id

  embedded_in :tool_delivery
  belongs_to :tool_type
  belongs_to :tool_brand

  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :received_quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true, allow_nil: true }
  validates_presence_of :tool_type_id, :tool_brand_id
  validates :tool_type_id, uniqueness: { scope: :tool_brand_id }
  validate :check_stock_and_set_tools, on: :create

  def check_stock_and_set_tools
    return if tool_type_id.blank? || tool_brand_id.blank? || errors.has_key?(:quantity)

    _tool_ids = Tool.stock.individual
                          .where(tool_type_id: tool_type_id,
                                 tool_brand_id: tool_brand_id,
                                 city_id: _parent.from_city_id)
                          .limit(quantity).pluck(:id)

    if _tool_ids.size < quantity
      errors.add(:quantity, :more_than_stock, count: _tool_ids.size)
    else
      self.tool_ids = _tool_ids
    end
  end

  def receive(received_quantity)
    self.received_quantity = received_quantity
    if self.received_quantity.blank?
      errors.add(:received_quantity, :blank)
    elsif self.received_quantity > quantity
      errors.add(:received_quantity, :less_than_or_equal_to, count: quantity)
    end

    if errors.empty?
      self.received_tool_ids = self.tool_ids[0...self.received_quantity]
      true
    else
      false
    end
  end
end

# 成套工具调货项
class ToolSuiteDelivery
  include Mongoid::Document

  # 发货数
  field :quantity, type: Integer
  # 实际收货数
  field :received_quantity, type: Integer
  field :tool_suite_inventory_ids, type: Array, default: []
  field :received_tool_suite_inventory_ids, type: Array, default: []

  embedded_in :tool_delivery
  belongs_to :tool_suite

  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :received_quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true, allow_nil: true }
  validates :tool_suite_id, presence: true, uniqueness: true
  validate :check_stock_and_set_suites, on: :create

  def check_stock_and_set_suites
    return if tool_suite_id.blank? || errors.has_key?(:quantity)

    inventory_ids = ToolSuiteInventory.stock.whole
                                            .where(tool_suite_id: tool_suite_id,
                                                   city_id: _parent.from_city_id)
                                            .limit(quantity).pluck(:id)

    if inventory_ids.size < quantity
      errors.add(:quantity, :more_than_stock, count: inventory_ids.size)
    else
      self.tool_suite_inventory_ids = inventory_ids
    end
  end

  def receive(received_quantity)
    self.received_quantity = received_quantity
    if self.received_quantity.blank?
      errors.add(:received_quantity, :blank)
    elsif self.received_quantity > quantity
      errors.add(:received_quantity, :less_than_or_equal_to, count: quantity)
    end

    if errors.empty?
      self.received_tool_suite_inventory_ids = self.tool_suite_inventory_ids[0...self.received_quantity]
      true
    else
      false
    end
  end
end

# 工具调货信息
class ToolDelivery
  include Mongoid::Document
  include Mongoid::Timestamps

  DELIVERY_TYPES = %w[part suite]

  field :delivery_type, type: String
  # 收货时间
  field :received_at, type: DateTime
  field :with_engineer_tools_count, type: Integer
  field :with_vehicle_tools_count, type: Integer
  field :with_engineer_suites_count, type: Integer
  field :with_vehicle_suites_count, type: Integer

  attr_accessible :to_city_id, :tool_delivery_items_attributes, :tool_suite_deliveries_attributes

  embeds_many :tool_delivery_items, :cascade_callbacks => true
  accepts_nested_attributes_for :tool_delivery_items, allow_destroy: true

  embeds_many :tool_suite_deliveries
  accepts_nested_attributes_for :tool_suite_deliveries, allow_destroy: true

  belongs_to :from_city, class_name: 'City'
  belongs_to :to_city, class_name: 'City'
  # 发货人
  belongs_to :deliverer, class_name: 'User'
  # 收货人
  belongs_to :recipient, class_name: 'User'

  validates :delivery_type, inclusion: { in: DELIVERY_TYPES }
  validates_presence_of :from_city_id, :to_city_id, :deliverer_id
  validates_presence_of :tool_delivery_items, if: Proc.new {|d| d.delivery_type == 'part'}
  validates_presence_of :tool_suite_deliveries, if: Proc.new {|d| d.delivery_type == 'suite'}

  before_validation :set_default_from_city, on: :create
  before_create :set_tools_count, :set_suites_count
  after_create :set_tools_for_delivering, :set_suites_for_delivering

  def self.statistics_summary
    match = {
      received_at: {'$exists' => false}
    }

    project = {
      to_city_id: 1,
      with_engineer_tools_count: '$with_engineer_tools_count',
      with_vehicle_tools_count: '$with_vehicle_tools_count',
      with_engineer_suites_count: '$with_engineer_suites_count',
      with_vehicle_suites_count: '$with_vehicle_suites_count'
    }

    group = {
      _id: {city_id: '$to_city_id'},
      with_engineer_tools_count: {'$sum' => '$with_engineer_tools_count'},
      with_vehicle_tools_count: {'$sum' => '$with_vehicle_tools_count'},
      with_engineer_suites_count: {'$sum' => '$with_engineer_suites_count'},
      with_vehicle_suites_count: {'$sum' => '$with_vehicle_suites_count'}
    }

    collection.aggregate(
      { '$match' => match },
      { '$project' => project },
      { '$group' => group }
    )
  end

  def suite?
    delivery_type == 'suite'
  end

  def part?
    delivery_type == 'part'
  end

  def tools_count
    with_engineer_tools_count + with_vehicle_tools_count
  end

  def suites_count
    with_engineer_suites_count + with_vehicle_suites_count
  end

  def set_tools_count
    return true if suite?

    self.with_engineer_tools_count = tool_delivery_items.sum do |item|
      item.tool_type.category == 'with_engineer' ? item.quantity : 0
    end

    self.with_vehicle_tools_count = tool_delivery_items.sum do |item|
      item.tool_type.category == 'with_vehicle' ? item.quantity : 0
    end
  end

  def set_suites_count
    return true if part?

    self.with_engineer_suites_count = tool_suite_deliveries.sum do |item|
      item.tool_suite.tool_type_category == 'with_engineer' ? item.quantity : 0
    end

    self.with_vehicle_suites_count = tool_suite_deliveries.sum do |item|
      item.tool_suite.tool_type_category == 'with_vehicle' ? item.quantity : 0
    end
  end

  def set_default_from_city
    self.from_city_id = City.beijing.id
  end

  def received_tools_count
    return if !received?
    return if suite?
    tool_delivery_items.sum { |item| item.received_tool_ids.size }
  end

  def received_suites_count
    return if !received?
    return if part?
    tool_suite_deliveries.sum { |item| item.received_tool_suite_inventory_ids.size }
  end

  def received?
    received_at.present?
  end

  def tools
    return [] if suite?
    Tool.where(:id.in => tool_delivery_items.map(&:tool_ids).flatten)
  end

  def suites
    return [] if part?
    ToolSuiteInventory.where(:id.in => tool_suite_deliveries.map(&:tool_suite_inventory_ids).flatten)
  end

  def received_tools
    return [] if !received?
    return [] if suite?
    Tool.where(:id.in => tool_delivery_items.map(&:received_tool_ids).flatten)
  end

  def received_suites
    return [] if !received?
    return [] if part?
    ToolSuiteInventory.where(:id.in => tool_suite_deliveries.map(&:received_tool_suite_inventory_ids).flatten)
  end

  def unreceived_tools
    return [] if !received?
    return [] if suite?
    ids = tool_delivery_items.map(&:tool_ids).flatten - tool_delivery_items.map(&:received_tool_ids).flatten
    Tool.where(:id.in => ids)
  end

  def unreceived_suites
    return [] if !received?
    return [] if part?
    ids = tool_suite_deliveries.map(&:tool_suite_inventory_ids).flatten -
      tool_suite_deliveries.map(&:received_tool_suite_inventory_ids).flatten
    ToolSuiteInventory.where(:id.in => ids)
  end

  def set_tools_for_delivering
    tools.update_all(tool_delivery_id: id, status: 'delivering') if part?
  end

  def set_suites_for_delivering
    suites.update_all(tool_delivery_id: id, status: 'delivering') if suite?
  end

  def receive(item_attrs, recipient)
    items = part? ? tool_delivery_items : tool_suite_deliveries

    can_be_received = item_attrs.inject(true) do |result, attr|
      item = items.find(attr[:id])
      item.receive(attr[:received_quantity]) && result
    end
    self.received_at = Time.current
    self.recipient = recipient

    if can_be_received && save
      set_tools_for_receiving
      set_suites_for_receiving
      true
    end
  end

  def set_tools_for_receiving
    return true if suite?
    received_tools.update_all(city_id: to_city_id, status: 'stock')
    unreceived_tools.update_all(city_id: from_city_id, status: 'stock')
  end

  def set_suites_for_receiving
    return true if part?
    received_suites.update_all(city_id: to_city_id, status: 'stock')
    unreceived_suites.update_all(city_id: from_city_id, status: 'stock')
  end
end
