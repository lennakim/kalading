# 城市信息
class City
  include Mongoid::Document

  scope :without_auto_submodels, -> { without(:auto_submodels) }

  field :name, type: String
  # 每日可以接单的数量
  field :order_capacity, type: Integer, default: 9999
  # 区号
  field :area_code, type: String, default: ''
  # 是否开放了上门业务
  field :opened, type: Boolean, default: false
  field :coordinates, type: Array, default: []

  validates :order_capacity, inclusion: { in: 1..9999 }, presence: true
  validates :name, presence: true
  validates :area_code, uniqueness: true, presence: true
  # 城市有很多行政区
  embeds_many :districts
  accepts_nested_attributes_for :districts, :allow_destroy => true

  belongs_to :parent, class_name: "City", :inverse_of => :child_cities
  has_many :child_cities, class_name: "City", :inverse_of => :parent

  # 城市有很多订单
  has_many :orders
  # 城市有很多仓库，点部
  has_many :storehouses
  # 城市有很多员工
  has_many :users
  # 城市有很多投诉单
  has_many :complaints
  # 城市可以属于一个车型年款
  has_and_belongs_to_many :auto_submodels
  # 城市有很多通知消息
  has_and_belongs_to_many :notifications

  def as_json(opts = nil)
    super except: [:order_capacity, :area_code, :opened, :auto_submodel_ids, :notification_ids, :complaint_ids]
  end

  # 本城市可以使用父城市的仓库
  def available_storehouses
    self.storehouses.where(type: 1) + (self.parent && self.parent.storehouses.where(type: 1)).to_a
  end

  # 本城市的技师服务子城市的订单
  def serve_orders
    Order.where(:city_id.in => [self.id] + self.child_cities.map(&:id))
  end
end
