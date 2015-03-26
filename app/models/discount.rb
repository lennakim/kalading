# 优惠券
class Discount
  include Mongoid::Document
  include Mongoid::Timestamps

  scope :recent, -> {order_by(created_at: :desc)}

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

  validates :times, inclusion: { in: 1..999999 }, presence: true
  validates :name, presence: true
  validates :percent, inclusion: { in: 0..100 }, presence: true
  has_and_belongs_to_many :orders
  has_and_belongs_to_many :service_types
  attr_accessible :name, :discount, :percent, :order_ids, :expire_date, :times, :final_price, :service_type_ids, :token

  paginates_per 10

  def generate_token six_length
    if six_length == 1
      begin
        self.token = [*"A".."Z", *"0".."1"].sample(6).join
      end until !Discount.find_by(token: self.token)
    else
      self.token = SecureRandom.uuid.delete '-'
    end
  end

end
