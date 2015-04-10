class ToolBatch
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer
  field :lifetime, type: Integer
  field :warranty_period, type: Integer
  field :price, type: Money

  attr_accessible :quantity, :lifetime, :warranty_period, :price, :tool_detail_id

  belongs_to :tool_detail
  belongs_to :tool_type
  belongs_to :tool_brand
  belongs_to :tool_supplier
  belongs_to :city
  belongs_to :operator, class_name: 'User'
  belongs_to :tool_stock
  has_many :tools, dependent: :destroy

  validates :quantity, numericality: { greater_than: 0, less_than: 100_000, only_integer: true }
  validates :lifetime, numericality: { greater_than: 0, less_than: 10*12, only_integer: true }
  validates :warranty_period, numericality: { greater_than: 0, less_than: 10*12, only_integer: true }
  validates :price, numericality: { greater_than: 0 }
  validates_presence_of :tool_detail_id, :tool_type_id, :tool_brand_id, :tool_supplier_id, :city_id, :operator_id

  before_validation :set_default_city, :set_tool_detail_attrs, on: :create
  before_create :increase_tool_stock
  after_create :generate_tools

  def set_default_city
    self.city_id = City.where(name: /\A北京/).first.id
  end

  def set_tool_detail_attrs
    %w[tool_type_id tool_brand_id tool_supplier_id].each do |attr|
      # self.tool_type_id = tool_detail.tool_type_id
      self.send("#{attr}=", tool_detail.send(attr))
    end
  end

  def increase_tool_stock
    tool_stock = ToolStock.where(city_id: city.id, tool_type_id: tool_type.id).first_or_create!
    tool_stock.inc(:remained_count, self.quantity)
    self.tool_stock = tool_stock
  end

  # 如果实际存在的工具数少于quantity，则创建少了的工具
  def correct_tools!
    (quantity - tools.count).times do
      Tool.create!(tool_batch_id: id)
    end
  end

  private

    def generate_tools
      quantity.times do
        Tool.create!(tool_batch_id: id)
      end
    end
end
