# 工具调货信息的一条明细
class ToolDeliveryItem
  include Mongoid::Document

  # 发货数
  field :quantity, type: Integer
  # 实际收货数
  field :received_quantity, type: Integer

  attr_accessible :quantity, :tool_type_id, :tool_brand_id

  embedded_in :tool_delivery
  belongs_to :tool_type
  belongs_to :tool_brand
  has_and_belongs_to_many :tools, inverse_of: nil

  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :received_quantity, numericality: { greater_than: 0, only_integer: true, allow_nil: true }
  validates_presence_of :tool_type_id, :tool_brand_id
  validates :tool_type_id, uniqueness: { scope: :tool_brand_id }

  before_create :check_stock_and_set_tools

  def check_stock_and_set_tools
    return if !valid?

    _tool_ids = Tool.stock.where(tool_type_id: tool_type_id,
                                 tool_brand_id: tool_brand_id,
                                 city_id: _parent.from_city_id)
                          .limit(quantity).pluck(:id)

    if _tool_ids.size < quantity
      errors.add(:quantity, :more_than_stock, count: _tool_ids.size)
      return false
    end

    self.tool_ids = _tool_ids
  end
end

# 工具调货信息
class ToolDelivery
  include Mongoid::Document
  include Mongoid::Timestamps

  # 收货时间
  field :received_at, type: DateTime

  attr_accessible :to_city_id, :tool_delivery_items_attributes

  embeds_many :tool_delivery_items, :cascade_callbacks => true
  accepts_nested_attributes_for :tool_delivery_items, allow_destroy: true

  belongs_to :from_city, class_name: 'City'
  belongs_to :to_city, class_name: 'City'
  # 发货人
  belongs_to :deliverer, class_name: 'User'
  # 收货人
  belongs_to :recipient, class_name: 'User'

  validates_presence_of :from_city_id, :to_city_id, :deliverer_id, :tool_delivery_items

  before_validation :set_default_from_city, on: :create
  after_create :set_tools_for_delivering

  def set_default_from_city
    self.from_city_id = City.beijing.id
  end

  def tools_count
    tool_delivery_items.sum { |item| item.tool_ids.size }
  end

  def set_tools_for_delivering
    Tool.where(:id.in => tool_delivery_items.map(&:tool_ids).flatten).update_all(tool_delivery_id: id)
  end

  def receive
  end
end
