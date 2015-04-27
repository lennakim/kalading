# 优惠券
class Discount
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  # 折扣金额
  field :discount, type: Money, default: 0
  # 一口价
  field :final_price, type: Money, default: 0
  # 打折百分比
  field :percent, type: Integer, default: 0
  # 过期时间
  field :expire_date, type: Date, default: Date.today.since(1.years)
  # 可使用次数。每个订单消耗一次
  field :times, type: Integer, default: 1
  # 优惠码
  field :token, type: String
  # 描述信息
  field :desc, type: String, default: ''

  validates :times, inclusion: { in: 1..999999 }, presence: true
  validates :name, presence: true
  validates :percent, inclusion: { in: 0..100 }, presence: true
  has_and_belongs_to_many :orders
  has_and_belongs_to_many :service_types
  attr_accessible :name, :discount, :percent, :order_ids, :expire_date, :times, :final_price, :service_type_ids, :token, :desc
  
  paginates_per 10
  
  def generate_token six_length
    if six_length == 1
      begin
        self.token = (('A'..'Z').to_a + (0..1).to_a).sample(6).join
      end until !Discount.find_by(token: self.token)
    else
      self.token = SecureRandom.uuid.delete '-'
    end
  end
  
  def available_times
    self.times - self.orders.count
  end
  
  def apply_to_order o
    return I18n.t(:discount_expired) if expire_date < Date.today
    return I18n.t(:discount_no_capacity) if orders.count > times
    # 优惠券的服务项目列表中任意一个项目都可以享受优惠，因此只要订单的服务项目列表有交集就可以用
    return I18n.t(:discount_service_types_error, s: self.service_types.map{|s| s.name}.join(',')) if service_types.present? and (service_type_ids & o.service_type_ids).empty?
    o.discounts << self
    return ''
  end
end
