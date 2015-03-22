# 备注
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :text, type: String

  embedded_in :order
end

# 订单
class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  #订单状态
  field :state, type: Integer, default: 0
  # 地址
  field :address, type: String, default: ''
  # 电话号码
  field :phone_num, type: String, default: ''
  # 客户姓名
  field :name, type: String, default: ''
  # 是否自购配件
  field :buymyself, type: Boolean, default: false
  # 上门服务时间
  field :serve_datetime, type: DateTime
  # 上门服务结束时间
  field :serve_end_datetime, type: DateTime
  # 车辆注册日期
  field :registration_date, type: Date
  # 车牌号第一位
  field :car_location, type: String, default: I18n.t(:jing)
  # 车牌号后6位
  field :car_num, type: String, default: ''
  # VIN号
  field :vin, type: String, default: ''
  # 优惠券号码
  field :discount_num, type: String, default: ''
  # 支付类型
  field :pay_type, type: Integer, default: 0
  # 发票类型
  field :reciept_type, type: Integer, default: 0
  # 发票抬头
  field :reciept_title, type: String, default: ''
  # 发票是否已经开了
  field :reciept_state, type: Integer, default: 0
  # 客户意见
  field :client_comment, type: String, default: ''
  # 取消原因
  field :cancel_reason, type: String, default: ''
  # 发票地址
  field :reciept_address, type: String, default: ''
  # 评分？
  field :evaluation_score, type: Integer, default: 0
  field :evaluation_tags, type: Array, default: []
  field :evaluation_time, type: DateTime
  field :location, type: Array, :default => [0.0, 0.0]

  # 已废弃
  field :oil_filter_changed, type: Boolean, default: false
  field :air_filter_changed, type: Boolean, default: false
  field :cabin_filter_changed, type: Boolean, default: false
  field :charged, type: Boolean, default: false
  field :oil_gathered, type: Boolean, default: false
  field :auto_km, type: String, default: ''
  field :oil_out, type: String, default: ''
  field :oil_in, type: String, default: ''
  field :front_wheels, type: String, default: ''
  field :back_wheels, type: String, default: ''
  field :auto_km_next, type: String, default: ''
  field :serve_datetime_next, type: DateTime
  # 已废弃end

  # 机动车所有人名字
  field :auto_owner_name, type: String, default: ->{ name }
  field :engine_num, type: String, default: ''
  field :client_id, type: String, default: ''
  # 网站登录使用的手机号
  field :login_phone_num, type: String, default: ''
  # 朋友的手机号
  field :friend_phone_num, type: String, default: ''
  # 接入号码
  field :incoming_call_num, type: String, default: ''
  # 使用账户余额付的款
  field :balance_pay, type: Money, default: 0.0
  # 价格，仅用于统计
  field :price, type: Money, default: 0.0
  # 属于技师
  belongs_to :engineer, class_name: "User", inverse_of: :serve_orders
  # 属于助理技师
  belongs_to :engineer2, class_name: "User", inverse_of: :serve_orders2
  # 属于调度
  belongs_to :dispatcher, class_name: "User", inverse_of: :serve_orders3
  belongs_to :friend, class_name: "Client", inverse_of: :friend_orders
  # 属于车辆
  belongs_to :auto
  # 属于一个车型年款
  belongs_to :auto_submodel
  # 服务项目列表
  has_and_belongs_to_many :service_types
  # 多个优惠券
  has_and_belongs_to_many :discounts
  embeds_many :pictures, :cascade_callbacks => true
  # 使用的配件列表辆
  has_and_belongs_to_many :parts
  # 多个备注，用于客服之间交流
  embeds_many :comments, :cascade_callbacks => true
  # 客户分类
  belongs_to :user_type
  # 所在城市
  belongs_to :city
  
  has_many :maintains

  field :part_counts, type: Hash, default: {}
  field :part_delivered_counts, type: Hash, default: {}
  field :part_deliver_state, type: Integer, default: 0
  
  # 固定的取消原因，cancel_reason放的是自定义原因
  field :cancel_type, type: Integer, default: 0

  accepts_nested_attributes_for :pictures, :allow_destroy => true
  accepts_nested_attributes_for :comments, :allow_destroy => true

  attr_accessible :state, :address, :phone_num,:buymyself,:serve_datetime,
    :customer_id, :engineer_id, :auto_id, :engineer2_id, :dispatcher_id, :friend_id, :balance_pay,
    :service_type_ids,
    :auto_id,
    :discount_ids,
    :part_ids,
    :picture_ids, :pictures_attributes,
    :comment_ids, :comments_attributes,
    :auto_submodel_id,
    :car_location, :car_num, :vin, :discount_num, :name, :pay_type, :reciept_type, :reciept_title, :reciept_state, :client_comment,
    :oil_filter_changed, :air_filter_changed, :cabin_filter_changed, :charged, :auto_km, :oil_out, :oil_in,
    :front_wheels, :back_wheels, :auto_km_next, :serve_datetime_next, :oil_gathered, :part_counts, :user_type_id, :auto_owner_name,
    :registration_date, :engine_num, :cancel_reason, :city_id, :reciept_address, :client_id, :part_deliver_state,
    :serve_end_datetime, :evaluation_score, :evaluation_tags, :evaluation_time, :login_phone_num, :friend_phone_num, :cancel_type,
    :incoming_call_num

  auto_increment :seq
  index({ seq: 1 })
  index({ state: 1 })
  index({ car_location: 1, car_num: 1})

  validates :phone_num, length: { in: 8..13 }, presence: true
  #validates :address, length: { in: 4..512 }, presence: true
  validates :city, presence: true
  validates_format_of :car_num, with: /^[a-zA-Z\d]*$/
  
  # 0: 未审核， 1：审核失败，2：未分配，3：未预约，4：已预约，5：服务完成，6：已交接，7：已回访，8：已取消，9：用户咨询, 10: 取消待审核
  STATES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  # 有效订单，用于统计
  VALID_STATES = [0, 2, 3, 4, 5, 6, 7]
  STATE_STRINGS = %w[unverified verify_error unassigned unscheduled scheduled serve_done handovered revisited service_cancelled inquiry cancel_pending]
  STATE_OPERATIONS = %w[verify reverify assign_engineer schedule serve_order handover revisit edit edit edit cancel_confirm]
  STATE_CHANGED_STRS = %w[reverify verify_failed verify_ok assign_ok schedule_ok serve_ok handover_ok revisit_ok]

  # 出库状态：0: 未出库，1：已出库，未回库，2：已回库
  PART_DELIVER_STATES = [0, 1, 2]
  PART_DELIVER_STATE_STRINGS = %w[not_delivered_yet delivered backed_to_store]

  PAY_TYPES = [0, 1]
  PAY_TYPE_STRINGS = %w[cash card]

  RECIEPT_TYPES = [0, 1, 2]
  RECIEPT_TYPE_STRINGS = %w[none personal firm]
  RECIEPT_STATES = [0, 1]
  RECIEPT_STATE_STRINGS = %w[not_wrote wrote]

  # 取消类型：0: 自定义取消原因，1：客户未到场，2：客户改约，3：配件错误。
  CANCEL_TYPES = [0, 1, 2, 3]
  CANCEL_TYPE_STRINGS = %w[custom_reason client_absent client_reschedule part_error]

  def calc_parts_price
    p = Money.new(0.0)
    self.parts.each do |pi|
      if pi.price && pi.price > 0.0
        price = pi.price
      else
        price = pi.url_price
      end
      p += ( price * self.part_counts[pi.id.to_s].to_i )
    end
    p
  end
  
  def parts_price_info
    s = ''
    self.parts_by_type.each do |k, v|
      p = Money.new(0.0)
      v.each do |pi|
        if pi.price && pi.price > 0.0
          price = pi.price
        else
          price = pi.url_price
        end
        p += ( price * self.part_counts[pi.id.to_s].to_i )
      end
      s += ( k.name + ' ' + p.to_s + ' ' )
    end
    s
  end

  
  def calc_service_price
    p = Money.new(0.0)
    self.service_types.each {|st| p += st.price if st.price }
    p
  end

  def services_price_info
    s = ''
    self.service_types.each do |st|
      s += ( st.name + ' ' + st.price.to_s + ' ' )
    end
    s
  end
  
  def calc_price
    price = Money.new(0.0)
    price += self.calc_service_price
    price += self.calc_parts_price
    self.discounts.each do |d|
      if d.final_price != 0
        price = d.final_price
      elsif d.discount != 0
        price -= d.discount
      elsif d.percent != 0
        price = price - price * d.percent / 100
      end
    end
    price = 0.0 if price < 0.0
    price - self.balance_pay
  end

  def parts_by_type
    self.parts.group_by {|part| part.part_type}
  end

  def price_without_discount
    self.calc_service_price + self.calc_parts_price
  end
  
  paginates_per 20
  
  def as_json(options = nil)
    super :only => [:_id, :seq ]
  end
  
  instance_eval do
    def within_datetime_range(states, d1, d2, city)
      any_in(:state => states).where(:serve_datetime.gte => d1, :serve_datetime.lte => d2, :city => city)
    end
  end

  after_create do |o|
    if STATE_STRINGS[o.state] != 'inquiry'
      p = o.calc_price
      # 使用账户余额
      if p > 0 && o.phone_num.present?
        # 查询或创建账户
        c = Client.find_or_create_by phone_num: o.phone_num
        if c && c.balance > 0.0
          used = [c.balance, p].min
          o.update_attributes balance_pay: used
          c.update_attributes balance: c.balance - used
        end
      end
      # 给朋友的账户加钱
      if o.friend_phone_num.present? && o.friend_phone_num != o.phone_num
        c = Client.find_by phone_num: o.friend_phone_num
        if c
          c.friend_orders << o
          c.update_attributes :balance => c.balance.to_f + 50.0
        end
      end
    end
  end
  
  before_create do |o|
    #临时的：去掉方括号之间的文字
    o.address.gsub!(/\[.*\]/, '') if o.address.present?
  end
  
  before_save :update_location
  
  def update_location
    if self.address.present?
      self.location = Map.get_latitude_longitude self.city.name, self.address
    end
  end
  
  instance_eval do
    # 待出库
    def to_be_delivered
      any_of({ state: 3 }, { state: 4 }).where(part_deliver_state: 0)
    end
    
    def to_be_delivered_hash
      {states: [3,4], part_deliver_state: 0}
    end
  
    # 待回库
    def to_be_backed
      any_of({ state: 5 }, { state: 8 }, {state: 10}).where(part_deliver_state: 1)
    end
    
    def to_be_backed_hash
      {states: [5, 8, 10], part_deliver_state: 1}
    end
    
    def valid_by_car_hash(car_location, car_num)
      { states: VALID_STATES, :car_location => car_location, :car_num => car_num }
    end
  end
  
  scope :valid, where(:state.in => VALID_STATES)
  scope :by_car, ->(car_location, car_num) { where(:car_location => car_location, :car_num => car_num) }
  
  def self.sum_by_city cities, field, start_time, end_time, conditions = {}
    total_sum = 0
    total_data = {}
    cities.where(opened: true).map do |city|
      key_op = [['year', '$year'], ['month', '$month'], ['day', '$dayOfMonth']]
      project_date_fields = Hash[*key_op.collect { |key, op| [key, {op => {'$add' => ["$#{field}", Time.zone.utc_offset*1000]}}] }.flatten]
      group_id_fields = Hash[*key_op.collect { |key, op| [key, "$#{key}"] }.flatten]
      pipeline = [
        {
          "$match" => {
            "city_id" => city.id,
            field => {"$gte" => start_time.utc, "$lte" => end_time.utc}
          }.merge(conditions)
        },
        {"$project" => project_date_fields },
        {"$group" => {"_id" => group_id_fields, "count" => {"$sum" => 1} } },
        {"$sort" => {field => -1}}
      ]
      #aggregate result: [{"_id"=>{"year"=>2015, "month"=>2, "day"=>5}, "count"=>2}
      a = collection.aggregate(pipeline)
      sum = a.sum {|v| v['count']}
      total_sum += sum
      {
        name: "#{city.name} (#{sum})",
        data:
          Hash[
            a.map do |v|
              d = DateTime.new(v['_id']['year'], v['_id']['month'], v['_id']['day'])
              total_data[d] ||= 0
              total_data[d] += v['count']
              [d, v['count']]
            end
          ]
      }
    end << {name: "#{I18n.t(:national)} (#{total_sum})", data: total_data}
  end
end
