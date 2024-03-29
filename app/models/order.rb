# 订单
class Order
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  scope :recent, -> { desc(:created_at) }

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
  field :pay_state, type: Integer, default: 0
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
  has_and_belongs_to_many :service_types, inverse_of: nil
  # 多个优惠券
  has_and_belongs_to_many :discounts
  embeds_many :pictures, :cascade_callbacks => true
  # 使用的配件列表辆
  has_and_belongs_to_many :parts, inverse_of: nil
  # 多个备注，用于客服之间交流
  embeds_many :comments, :cascade_callbacks => true
  # 客户分类
  belongs_to :user_type
  # 所在城市
  belongs_to :city

  has_many :maintains

  has_one :evaluation

  field :part_counts, type: Hash, default: {}
  field :part_delivered_counts, type: Hash, default: {}
  field :part_deliver_state, type: Integer, default: 0

  # 固定的取消原因，cancel_reason放的是自定义原因
  field :cancel_type, type: Integer, default: 0

  accepts_nested_attributes_for :pictures, :allow_destroy => true
  accepts_nested_attributes_for :comments, :allow_destroy => true

  attr_accessible :state, :address, :phone_num,:buymyself,:serve_datetime,
    :customer_id, :engineer_id, :auto_id, :engineer2_id, :dispatcher_id, :friend_id, :balance_pay,
    :service_type_ids, :pay_state,
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

  def self.state_val(s)
    Order::STATE_STRINGS.index s
  end

  # 出库状态：0: 未出库，1：已出库，未回库，2：已回库
  NOT_DELIVERED_YET_STATE = 0
  DELIVERED_STATE         = 1
  BACKED_TO_STORE_STATE   = 2
  PART_DELIVER_STATES = [NOT_DELIVERED_YET_STATE, DELIVERED_STATE, BACKED_TO_STORE_STATE]
  PART_DELIVER_STATE_STRINGS = %w[not_delivered_yet delivered backed_to_store]

  PAY_TYPES = [0, 1, 2, 3]
  PAY_TYPE_STRINGS = %w[cash card wechatpay alipay]
  ONLINE_PAY_TYPES = [2, 3]
  PAY_STATES = [0, 1, 2, 3]
  PAY_STATE_STRINGS = %w[unpaid paid refunding refunded]

  RECIEPT_TYPES = [0, 1, 2]
  RECIEPT_TYPE_STRINGS = %w[none personal firm]
  RECIEPT_STATES = [0, 1]
  RECIEPT_STATE_STRINGS = %w[not_wrote wrote]


  # 取消类型：0: 自定义取消原因，1：客户未到场，2：客户改约，3：配件错误。
  CANCEL_TYPES = [0, 1, 2, 3]
  CANCEL_TYPE_STRINGS = %w[custom_reason client_absent client_reschedule part_error]

  scope :from_this_month, -> { between(serve_datetime: (Time.now.beginning_of_month .. Time.now.end_of_month)) }

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

  def parts_auto_deliver
    storehouse = self.city.available_storehouses.first
    deliver_done = 1
    self.parts.each do |p|
      quantity = self.part_counts[p.id.to_s].to_i - self.part_delivered_counts[p.id.to_s].to_i
      next if quantity <= 0
      partbatches = p.partbatches.where(storehouse: storehouse).asc(:created_at)
      if partbatches.sum(&:remained_quantity) < quantity
        deliver_done = 0
        next
      end

      self.part_delivered_counts[p.id.to_s] ||= 0
      need_q = quantity
      partbatches.each do |pb|
        c = [need_q, pb.remained_quantity].min
        pb.update_attribute :remained_quantity, pb.remained_quantity - c
        pb.part.auto_submodels.each do |asm|
          asm.on_part_inout pb.part, -c
        end
        need_q -= c
        break if need_q <= 0
      end
      self.part_delivered_counts[p.id.to_s] += quantity
    end
    self.part_deliver_state = 1 if deliver_done == 1
    deliver_done
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
    #优惠券描述加入客户意见中
    o.client_comment += ('－－' + o.discounts.first.desc) if !o.discounts.empty? && !o.discounts.first.desc.blank?
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

  # 统计某个时间段每种配件的出库量
  def self.part_deliver_stats d1, d2
    map = %Q{
      function() {
        for( var part_id in this.part_delivered_counts) {
          if (this.part_delivered_counts.hasOwnProperty(part_id)) {
            c = parseInt(this.part_delivered_counts[part_id]);
            if (!isNaN(c) && c > 0)
              emit(part_id, c);
          }
        }
      }
    }
    reduce = %Q{
      function(key, values) {
        return Array.sum(values);
      }
    }
    Hash[Order.valid.between(:serve_datetime => d1..d2).map_reduce(map, reduce).out(inline: true).map { |data| [data['_id'].to_s, data['value'].to_i] }]
  end
  
  # 统计某种配件的出库量
  def self.part_deliver_stats_by_type pt
    map = %Q{
      function() {
        for( var part_id in this.part_delivered_counts) {
          if (this.part_delivered_counts.hasOwnProperty(part_id)) {
            c = parseInt(this.part_delivered_counts[part_id]);
            if (!isNaN(c) && c > 0)
              emit(part_id, c);
          }
        }
      }
    }
    reduce = %Q{
      function(key, values) {
        return Array.sum(values);
      }
    }
    part_ids = Part.where(part_type: pt).map {|p| p.id }
    # 两个Hash:按规格和按品牌
    h1 = {}
    h2 = {}
    Order.valid.where(:part_ids.in => part_ids).map_reduce(map, reduce).out(inline: true).select{|data| part_ids.include?(Moped::BSON::ObjectId(data['_id']))}.each do |data|
      p = Part.find data['_id']
      k2 = p.part_brand.name
      k = k2 + ' ' + p.spec
      h1[k] ||= 0
      h1[k] += data['value'] * p.capacity
      h2[k2] ||= 0
      h2[k2] += data['value'] * p.capacity
    end
    total = h1.sum {|k, v| v}
    h3 = {}
    h4 = {}
    h1.each do |k, v|
      h3[k + ', ' + (v * 100 / total).to_i.to_s + '%'] = v
    end
    h2.each do |k, v|
      h4[k + ', ' + (v * 100 / total).to_i.to_s + '%'] = v
    end
    [h3, h4]
  end

  track_history :track_create   =>  false,
                :track_update   =>  true,
                :track_destroy  =>  false,
                :on => [:state, :address, :phone_num, :name, :serve_datetime, :registration_date, :car_location, :car_num, :discount_num, :pay_type, :cancel_reason, :incoming_call_num, :engineer, :engineer2, :dispatcher,
                        :auto_submodel, :service_type_ids, :part_ids, :engine_num, :vin, :part_deliver_state, :auto_owner_name, :part_delivered_counts, :part_counts]

  # api
  def license_plate
    car_location + car_num
  end

  def brand_logo
    auto_submodel.auto_model.auto_brand.logo if auto_submodel
  end

  def brand_name
    auto_submodel.auto_model.auto_brand.name if auto_submodel
  end

  def model_name
    auto_submodel.auto_model.name if auto_submodel
  end

  def model_engine_displacement
    auto_submodel.engine_displacement if auto_submodel
  end

  def model_year_range
    auto_submodel.year_range if auto_submodel
  end

  def order_state
    "#{self.state}-#{I18n.t(Order::STATE_STRINGS[self.state])}"
  end

  def order_pay_type
    "#{self.pay_type}-#{I18n.t(PAY_TYPE_STRINGS[self.pay_type])}"
  end

  def evaluated
    evaluation?
  end

  def parts_detail
    ps = []
    parts.each do |p|
      ps << {
        :brand => p.part_brand.name,
        :type => p.part_type.name,
        :number => p.number,
        :price => p.ref_price.to_f * self.part_counts[p.id.to_s].to_i
      }
    end
    ps
  end

  def services_desc
    (service_types.size > 1) ? I18n.t(:auto_maintain_desc) : (I18n.t(:service_desc_pre) + service_types.first.name)
  end

  def need_online_pay
    pay_state == PAY_STATE_STRINGS.index('unpaid') && ONLINE_PAY_TYPES.include?(pay_type)
  end
end
