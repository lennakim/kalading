class Tool
  include Mongoid::Document
  include Mongoid::Timestamps

  field :lifetime, type: Integer
  field :warranty_period, type: Integer
  field :price, type: Money
  # 进货时间
  field :batch_created_at, type: DateTime
  # 工具编号
  field :tool_number, type: String
  # 是否分配
  field :assigned, type: Boolean, default: false

  attr_accessible :tool_batch_id

  belongs_to :tool_batch
  belongs_to :tool_type
  belongs_to :tool_brand
  belongs_to :tool_supplier
  belongs_to :city
  belongs_to :tool_delivery

  validates :lifetime, numericality: { greater_than: 0, only_integer: true }
  validates :warranty_period, numericality: { greater_than: 0, only_integer: true }
  validates :price, numericality: { greater_than: 0 }
  validates_presence_of :tool_batch_id, :tool_type_id, :tool_brand_id, :tool_supplier_id, :city_id

  before_validation :set_tool_batch_attrs, on: :create

  scope :stock, -> { where(tool_delivery_id: nil) }
  scope :delivering, -> { where(:tool_delivery_id.ne => nil) }

  def set_tool_batch_attrs
    %w[tool_type_id tool_brand_id tool_supplier_id city_id lifetime warranty_period price].each do |attr|
      # self.tool_type_id = tool_batch.tool_type_id
      self.send("#{attr}=", tool_batch.send(attr))
    end
    self.batch_created_at = tool_batch.created_at
  end

  def delivering?
    tool_delivery_id.present?
  end
end
