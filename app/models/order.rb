class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :text, type: String

  embedded_in :order
end

class Order
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  track_history :track_create   =>  true,    # track document creation, default is false
                :track_update   =>  true,     # track document updates, default is true
                :track_destroy  =>  true     # track document destruction, default is false

  field :state, type: Integer, default: 0
  field :address, type: String
  field :phone_num, type: String
  field :name, type: String
  field :buymyself, type: Boolean, default: false
  field :serve_datetime, type: DateTime
  field :price, type: Money
  field :car_location, type: String, default: I18n.t(:jing)
  field :car_num, type: String, default: ''
  field :vin, type: String, default: ''
  field :discount_num, type: String, default: ''
  field :pay_type, type: Integer, default: 0
  field :reciept_type, type: Integer, default: 0
  field :reciept_title, type: String, default: ''
  field :client_comment, type: String, default: ''

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
  
  belongs_to :customer, class_name: "User", inverse_of: :buy_orders, index: true
  belongs_to :engineer, class_name: "User", inverse_of: :serve_orders

  belongs_to :auto
  belongs_to :auto_submodel
  has_and_belongs_to_many :service_types
  has_and_belongs_to_many :discounts
  embeds_many :pictures, :cascade_callbacks => true
  has_and_belongs_to_many :parts
  embeds_many :comments, :cascade_callbacks => true

  field :part_counts, type: Hash, default: {}
  
  accepts_nested_attributes_for :pictures, :allow_destroy => true
  accepts_nested_attributes_for :comments, :allow_destroy => true

  attr_accessible :state, :address, :phone_num,:buymyself,:serve_datetime,
    :customer_id, :engineer_id, :auto_id,
    :service_type_ids,
    :auto_id,
    :discount_ids,
    :part_ids,
    :picture_ids, :pictures_attributes,
    :comment_ids, :comments_attributes,
    :auto_submodel_id,
    :car_location, :car_num, :vin, :discount_num, :name, :pay_type, :reciept_type, :reciept_title, :client_comment,
    :oil_filter_changed, :air_filter_changed, :cabin_filter_changed, :auto_km, :oil_out, :oil_in,
    :front_wheels, :back_wheels, :auto_km_next, :serve_datetime_next, :oil_gathered, :part_counts

  auto_increment :seq
  index({ seq: 1 })
  index({ state: 1 })
  index({ car_location: 1, car_num: 1})

  validates :car_num, length: { in: 6..6 }, presence: true
  validates :phone_num, length: { in: 8..13 }, presence: true
  validates :address, length: { in: 4..512 }, presence: true
  validates :auto_submodel_id, presence: true
  
  STATES = [0, 1, 2, 3, 4, 5, 6, 7]
  STATE_STRINGS = %w[unverified verify_error unassigned unscheduled scheduled serve_done handovered revisited]
  STATE_OPERATIONS = %w[verify reverify assign_engineer schedule serve_order handover revisit edit]
  STATE_CHANGED_STRS = %w[reverify verify_failed verify_ok assign_ok schedule_ok serve_ok handover_ok revisit_ok]

  PAY_TYPES = [0, 1]
  PAY_TYPE_STRINGS = %w[cash card]

  RECIEPT_TYPES = [0, 1, 2]
  RECIEPT_TYPE_STRINGS = %w[none personal firm]

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
      next if d.expire_date < Date.today
      if d.discount != 0
        self.price -= d.discount
      elsif d.percent != 0
        self.price = self.price - self.price * d.percent / 100
      end
    end
    self.price
  end

  def parts_by_type
    self.parts.group_by {|part| part.part_type}
  end

  paginates_per 10
end
