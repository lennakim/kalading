class Tool
  include Mongoid::Document
  include Mongoid::Timestamps

  STATUSES = %w[stock delivering assigned discarded]

  field :lifetime, type: Integer
  field :warranty_period, type: Integer
  field :price, type: Money
  # 进货时间
  field :batch_created_at, type: DateTime
  # 工具编号
  field :tool_number, type: String
  field :status, type: String, default: 'stock'
  field :tool_type_category, type: String

  attr_accessible :tool_batch_id

  belongs_to :tool_batch
  belongs_to :tool_type
  belongs_to :tool_brand
  belongs_to :tool_supplier
  belongs_to :city
  # 如果要能多次调货，就
  # has_and_belongs_to_many :tool_deliveries
  belongs_to :tool_delivery
  belongs_to :tool_suite_inventory

  validates :lifetime, numericality: { greater_than: 0, only_integer: true }
  validates :warranty_period, numericality: { greater_than: 0, only_integer: true }
  validates :price, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }
  validates_presence_of :tool_batch_id, :tool_type_id, :tool_brand_id, :tool_supplier_id, :city_id

  before_validation :set_tool_batch_attrs, on: :create
  before_create :set_tool_type_category

  scope :stock, -> { where(status: 'stock') }
  scope :delivering, -> { where(status: 'delivering') }
  scope :individual, -> { where(tool_suite_inventory_id: nil) }

  # 暂时没有使用
  def self.statistics_summary
    statistics_statuses = %w[stock delivering assigned]

    match = {
      status: {'$in' => statistics_statuses},
      tool_suite_inventory_id: nil
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

  # 暂时没有使用
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

  def self.statistics_with_city_and_tool_type(options)
    match = {}
    if options[:city_id].present?
      match[:city_id] = Moped::BSON::ObjectId(options[:city_id])
    end
    if options[:tool_type_id].present?
      match[:tool_type_id] = Moped::BSON::ObjectId(options[:tool_type_id])
    end

    project = {
      city_id: 1,
      tool_type_id: 1,
      tool_brand_id: 1,
      status: 1
    }

    group = {
      _id: {city_id: '$city_id', tool_type_id: '$tool_type_id'},
      total: {'$sum' => 1}
    }
    # 如果既选了城市又选了工具类型，则查询细分到工具品牌
    if options[:city_id].present? && options[:tool_type_id].present?
      group[:_id].merge!(tool_brand_id: '$tool_brand_id')
    end

    %w[stock delivering assigned].each do |status|
      group[status] = {
        '$sum' => {
          # '$status' == 'stock' ? 1 : 0
          '$cond' => [{'$eq' => ['$status', status]}, 1, 0]
        }
      }
    end

    collection.aggregate(
      { '$match' => match },
      { '$project' => project },
      { '$group' => group }
    )
  end

  def set_tool_batch_attrs
    %w[tool_type_id tool_brand_id tool_supplier_id city_id lifetime warranty_period price].each do |attr|
      # self.tool_type_id = tool_batch.tool_type_id
      self.send("#{attr}=", tool_batch.send(attr))
    end
    self.batch_created_at = tool_batch.created_at
  end

  def set_tool_type_category
    self.tool_type_category = tool_type.category
  end

  def mark_as_assigned(tool_number = nil)
    self.tool_number = tool_number.try(:strip)
    self.status = 'assigned'
    self.save(validate: false)
  end

  def approve_discarded
    self.status = 'discarded'
    self.save(validate: false)
  end
end
