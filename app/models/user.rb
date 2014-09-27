class User
  include Mongoid::Document
  include Mongoid::Timestamps
  Devise::Models::TokenAuthenticatable
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""
  field :authentication_token, :type => String
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  field :name,    :type => String
  field :name_pinyin,    :type => String
  field :phone_num,    :type => String
  field :phone_num2,    :type => String
  field :remark,    :type => String
  field :weixin_num,    :type => String
  field :roles,    :type => Array, :default => [0]
  field :title, :default => ''
  
  attr_accessible :name, :name_pinyin, :phone_num, :email, :roles, :password, :password_confirmation, :autos_ids, :phone_num2, :remark, :weixin_num, :title
  
  has_and_belongs_to_many :autos
  accepts_nested_attributes_for :autos, :allow_destroy => true
  
  has_many :serve_orders, class_name: "Order", inverse_of: :engineer
  has_many :serve_orders2, class_name: "Order", inverse_of: :engineer2
  has_many :serve_orders3, class_name: "Order", inverse_of: :dispatcher
  has_many :partbatches
  
  validates_uniqueness_of :phone_num, :allow_blank => true

  ROLES = [0, 1, 2, 3, 4, 5, 6]
  ROLE_STRINGS = %w[customer role_admin manager storehouse_admin data_admin engineer dispatcher]
  
  def role_str
    self.roles.map {|s| I18n.t(User::ROLE_STRINGS[s.to_i])}.join(',')
  end
  
  def name_and_order_num
    self.name + I18n.t(:order_num, n: self.serve_orders.where(:state.lt => 6).count )
  end
  
  paginates_per 10
  
  def ability
    @ability ||= Ability.new(self)
  end

  def self.storehouse_admins
    User.all.select {|u| u.ability.can? :create, Partbatch}
  end
end
