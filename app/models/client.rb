# 客户的账户
class Client
  include Mongoid::Document
  include Mongoid::Timestamps
  Devise::Models::TokenAuthenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  # 手机号
  field :phone_num, type: String
  # 账户余额
  field :balance, type: Money, default: 0.0
  
  index({ phone_num: 1 })
  validates :phone_num, length: { in: 8..13 }, presence: true

  attr_accessible :phone_num, :balance, :friend_orders_ids
  # 客户的朋友下单，给予客户积分奖励
  has_many :friend_orders, class_name: "Order", inverse_of: :friend
  
  def as_json(options = nil)
    h = super :except => [:_id, :created_at, :updated_at, :balance ]
    h[:balance] = self.balance.to_f
    h
  end
end