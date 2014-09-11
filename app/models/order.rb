class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :text, type: String

  embedded_in :order
end

class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :state, type: Integer, default: 0
  field :address, type: String, default: ''
  field :phone_num, type: String, default: ''
  field :name, type: String, default: ''
  field :buymyself, type: Boolean, default: false
  field :serve_datetime, type: DateTime
  field :serve_end_datetime, type: DateTime
  field :registration_date, type: Date
  field :price, type: Money
  field :car_location, type: String, default: I18n.t(:jing)
  field :car_num, type: String, default: ''
  field :vin, type: String, default: ''
  field :discount_num, type: String, default: ''
  field :pay_type, type: Integer, default: 0
  field :reciept_type, type: Integer, default: 0
  field :reciept_title, type: String, default: ''
  field :client_comment, type: String, default: ''
  field :cancel_reason, type: String, default: ''
  field :reciept_address, type: String, default: ''
  field :evaluation, type: String, default: ''
  field :evaluation_score, type: Integer, default: 0
  field :evaluation_tags, type: Array, default: [0]
  field :evaluation_time, type: DateTime

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
  field :auto_owner_name, type: String, default: ->{ name }
  field :engine_num, type: String, default: ''
  field :client_id, type: String, default: ''

  belongs_to :engineer, class_name: "User", inverse_of: :serve_orders
  belongs_to :engineer2, class_name: "User", inverse_of: :serve_orders2

  belongs_to :auto
  belongs_to :auto_submodel
  has_and_belongs_to_many :service_types
  has_and_belongs_to_many :discounts
  embeds_many :pictures, :cascade_callbacks => true
  has_and_belongs_to_many :parts
  embeds_many :comments, :cascade_callbacks => true
  belongs_to :user_type
  belongs_to :city
  
  has_many :maintains

  field :part_counts, type: Hash, default: {}
  field :part_delivered_counts, type: Hash, default: {}
  field :part_deliver_state, type: Integer, default: 0
  
  accepts_nested_attributes_for :pictures, :allow_destroy => true
  accepts_nested_attributes_for :comments, :allow_destroy => true

  attr_accessible :state, :address, :phone_num,:buymyself,:serve_datetime,
    :customer_id, :engineer_id, :auto_id, :engineer2_id,
    :service_type_ids,
    :auto_id,
    :discount_ids,
    :part_ids,
    :picture_ids, :pictures_attributes,
    :comment_ids, :comments_attributes,
    :auto_submodel_id,
    :car_location, :car_num, :vin, :discount_num, :name, :pay_type, :reciept_type, :reciept_title, :client_comment,
    :oil_filter_changed, :air_filter_changed, :cabin_filter_changed, :charged, :auto_km, :oil_out, :oil_in,
    :front_wheels, :back_wheels, :auto_km_next, :serve_datetime_next, :oil_gathered, :part_counts, :user_type_id, :auto_owner_name,
    :registration_date, :engine_num, :cancel_reason, :city_id, :reciept_address, :client_id, :part_deliver_state,
    :serve_end_datetime, :evaluation, :evaluation_score, :evaluation_tags, :evaluation_time

  auto_increment :seq
  index({ seq: 1 })
  index({ state: 1 })
  index({ car_location: 1, car_num: 1})

  validates :phone_num, length: { in: 8..13 }, presence: true
  validates :address, length: { in: 4..512 }, presence: true
  validates :city, presence: true
  
  # 0: 未审核， 1：审核失败，2：未分配，3：未预约，4：已预约，5：服务完成，6：已交接，7：已回访，8：已取消，9：用户咨询
  STATES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  STATE_STRINGS = %w[unverified verify_error unassigned unscheduled scheduled serve_done handovered revisited service_cancelled inquiry]
  STATE_OPERATIONS = %w[verify reverify assign_engineer schedule serve_order handover revisit edit edit edit]
  STATE_CHANGED_STRS = %w[reverify verify_failed verify_ok assign_ok schedule_ok serve_ok handover_ok revisit_ok]

  # 出库状态：0: 未出库，1：已出库，未回库，2：已回库
  PART_DELIVER_STATES = [0, 1, 2]
  PART_DELIVER_STATE_STRINGS = %w[not_delivered_yet delivered backed_to_store]

  PAY_TYPES = [0, 1]
  PAY_TYPE_STRINGS = %w[cash card]

  RECIEPT_TYPES = [0, 1, 2]
  RECIEPT_TYPE_STRINGS = %w[none personal firm]
  
  EVALUATION_TAG = [0, 1, 2, 3, 4]
  EVALUATION_TAG_STRINGS = %w[none service_resp_quickly service_resp_quickly service_good service_bad]

  before_save :calc_price
  
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
    self.price = 0.0
    self.price += self.calc_service_price
    self.price += self.calc_parts_price
    self.discounts.each do |d|
      next if d.expire_date < Date.today || d.orders.count >= d.times
      if d.discount != 0
        self.price -= d.discount
      elsif d.percent != 0
        self.price = self.price - self.price * d.percent / 100
      end
    end
    self.price = 0.0 if self.price < 0.0
    self.price
  end

  def parts_by_type
    self.parts.group_by {|part| part.part_type}
  end

  def price_without_discount
    self.calc_service_price + self.calc_parts_price
  end
  
  paginates_per 100
  
  def as_json(options = nil)
    h = super :except => [:_id, :air_filter_changed, :auto_id, :auto_km, :auto_km_next, :back_wheels,:cabin_filter_changed, :client_comment, :created_at ,:customer_id, :discount_ids,
      :discount_num,:engineer_id, :front_wheels, :modifier_id, :oil_filter_changed, :oil_gathered, :oil_in, :oil_out,
      :phone_num  ,:serve_datetime ,:serve_datetime_next ,:updated_at, :version, :vin, :charged, :state, 
      :part_counts, :address, :buymyself, :car_location, :car_num, :name, :pay_type, :reciept_title, :reciept_type, :seq, :part_ids, :service_type_ids,
      :auto_submodel_id, :price, :comments, :evaluation, :evaluation_score, :evaluation_tags, :evaluation_time ]
  end
  
  instance_eval do
    def within_datetime_range(s1, s2, d1, d2, city)
      where :state.gte => s1, :state.lte => s2, :serve_datetime.gte => d1, :serve_datetime.lte => d2, :city => city
    end
  end

end
