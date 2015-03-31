# 这个model和order.rb里面的Comment重复了，应该删除
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :text, type: String

  embedded_in :complaint
end

# 投诉单
class Complaint
  include Mongoid::Document
  include Mongoid::Timestamps

  field :state, type: Integer, default: 0
  field :customer_name, type: String, default: ''
  field :customer_phone_num, type: String, default: ''
  field :source, type: String
  field :detail, type: String
  field :handled_result, type: String
  field :handled_datetime, type: DateTime
  field :severity_level, type: Integer, default: 0
  # 投诉针对一个订单
  belongs_to :order
  # 投诉使用tag进行分类
  belongs_to :tag
  # 投诉单创建者
  belongs_to :creater, class_name: "User", inverse_of: :complaints_created
  # 被投诉的对象
  belongs_to :complained, class_name: "User", inverse_of: :complaints_complained
  # 投诉的处理者
  belongs_to :handler, class_name: "User", inverse_of: :complaints_handled
  # 投诉所在城市.因为订单不是必选的
  belongs_to :city
  # 备注信息
  embeds_many :comments, :cascade_callbacks => true

  STATES = [0, 1]
  STATE_STRINGS = %w[not_handled handled]
  SEVERITY_LEVELS = [0, 1, 2]
  SEVERITY_LEVEL_STRINGS = %w[general serious very_serious]

  auto_increment :seq
  index({ seq:1 })
  validates :tag, presence: true
  validates :customer_name, presence: true
  validates :customer_phone_num, presence: true
  
  accepts_nested_attributes_for :comments, :allow_destroy => true

  attr_accessible :seq, :state, :customer_name, :customer_phone_num, :severity_level, :source, :order_id, :creater_id, :complained_id, :handler_id, :tag_id, :comments_attributes, :detail, :handled_result, :city_id
end
