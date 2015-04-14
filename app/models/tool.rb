class Tool
  include Mongoid::Document
  include Mongoid::Timestamps

  STATUSES = %w[stock delivering assigned]

  field :lifetime, type: Integer
  field :warranty_period, type: Integer
  field :price, type: Money
  # 进货时间
  field :batch_created_at, type: DateTime
  # 工具编号
  field :tool_number, type: String
  field :status, type: String, default: 'stock'

  attr_accessible :tool_batch_id

  belongs_to :tool_batch
  belongs_to :tool_type
  belongs_to :tool_brand
  belongs_to :tool_supplier
  belongs_to :city
  # 如果要能多次调货，就
  # has_and_belongs_to_many :tool_deliveries
  belongs_to :tool_delivery

  validates :lifetime, numericality: { greater_than: 0, only_integer: true }
  validates :warranty_period, numericality: { greater_than: 0, only_integer: true }
  validates :price, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }
  validates_presence_of :tool_batch_id, :tool_type_id, :tool_brand_id, :tool_supplier_id, :city_id

  before_validation :set_tool_batch_attrs, on: :create

  scope :stock, -> { where(status: 'stock') }
  scope :delivering, -> { where(status: 'delivering') }

  def self.statistics_with_city_and_tool_type(options)
    match = {}
    if options[:city_id].present?
      match[:city_id] = Moped::BSON::ObjectId(options[:city_id])
    end
    if options[:tool_type_id].present?
      match[:tool_type_id] = Moped::BSON::ObjectId(options[:tool_type_id])
    end

    group = {}
    group[:_id] = {city_id: '$city_id', tool_type_id: '$tool_type_id'}
    # 如果既选了城市又选了工具类型，则查询细分到工具品牌
    if options[:city_id].present? && options[:tool_type_id].present?
      group[:_id].merge!(tool_brand_id: '$tool_brand_id')
    end

    STATUSES.each do |status|
      group[status] = {
        '$sum' => {
          # '$status' == 'stock' ? 1 : 0
          '$cond' => [{'$eq' => ['$status', status]}, 1, 0]
        }
      }
    end
    group[:total] = {'$sum' => 1}

    collection.aggregate(
      { '$match' => match },
      { '$group' => group }
    )
  end

  # data:
  # [
  #   {
  #     "_id"=>{"city_id"=>"5307033e098e719c45000043", "tool_type_id"=>"550fde8a311f90ddbb000001"},
  #     "stock"=>98, "delivering"=>1, "assigned"=>0, "total"=>99
  #   },
  #   {...}
  # ]
  def self.statistics_to_objects(data)
    return [] if data.blank?

    # models_by_key:
    # {
    #   'city_id' => City,
    #   'tool_type_id' => ToolType
    # }
    models_by_key = {}
    data.first['_id'].each do |key, _|
      models_by_key[key] = key.gsub(/_id\Z/, '').camelize.constantize
    end

    # objs_by_id:
    # {
    #   'city_id-5307033e098e719c45000043' => city1,
    #   'tool_type_id-550fde8a311f90ddbb000001' => tool_type1,
    #   ...
    # }
    objs_by_id = {}
    data.each do |datum|
      datum['_id'].each do |key, id|
        objs_by_id["#{key}-#{id}"] ||= models_by_key[key].find(id)
      end
    end

    data.map do |datum|
      obj = OpenStruct.new
      datum['_id'].each do |key, id|
        obj[key.gsub(/_id\Z/, '')] = objs_by_id["#{key}-#{id}"]
      end

      (datum.keys - ['_id']).each do |key|
        obj[key] = datum[key]
      end

      obj
    end
  end

  def set_tool_batch_attrs
    %w[tool_type_id tool_brand_id tool_supplier_id city_id lifetime warranty_period price].each do |attr|
      # self.tool_type_id = tool_batch.tool_type_id
      self.send("#{attr}=", tool_batch.send(attr))
    end
    self.batch_created_at = tool_batch.created_at
  end
end
