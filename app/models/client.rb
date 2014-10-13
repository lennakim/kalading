class Client
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :phone_num, type: String
  # 账户余额
  field :balance, type: Money, default: 0.0
  
  index({ phone_num: 1 })
  validates :phone_num, length: { in: 8..13 }, presence: true

  attr_accessible :phone_num, :balance, :friend_orders_ids
  
  has_many :friend_orders, class_name: "Order", inverse_of: :friend
  
  def as_json(options = nil)
    h = super :except => [:_id, :created_at, :updated_at, :balance ]
    h[:balance] = self.balance.to_f
    h
  end

end