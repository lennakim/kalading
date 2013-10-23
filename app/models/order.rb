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
  field :buymyself, type: Boolean, default: false
  field :serve_datetime, type: DateTime
  field :price, type: Money
  field :car_location, type: String, default: I18n.t(:jing)
  field :car_num, type: String, default: ''
  
  belongs_to :customer, class_name: "User", inverse_of: :buy_orders
  belongs_to :engineer, class_name: "User", inverse_of: :serve_orders

  belongs_to :auto
  belongs_to :auto_submodel
  has_many :service_items, dependent: :delete
  has_many :discounts, dependent: :delete
  embeds_many :pictures, :cascade_callbacks => true
  embeds_many :part_items, :cascade_callbacks => true
  
  accepts_nested_attributes_for :pictures, :allow_destroy => true
  accepts_nested_attributes_for :service_items, :allow_destroy => true
  accepts_nested_attributes_for :part_items, :allow_destroy => true

  attr_accessible :state, :address, :phone_num,:buymyself,:serve_datetime,
    :customer_id, :engineer_id, :auto_id,
    :service_item_ids, :service_items_attributes,
    :auto_id,
    :discount_ids, :discounts_attributes,
    :part_ids,
    :picture_ids, :pictures_attributes,
    :part_item_ids, :part_items_attributes,
    :auto_submodel_id,
    :car_location, :car_num
    
    
  index({ state: 1 })
  
  STATES = [0, 1, 2, 3, 4, 5, 6, 7]
  STATE_STRINGS = %w[unverified verify_error unassigned unscheduled scheduled serve_done handovered revisited]

  before_save :calc_price
  
  def service_prices
    s = ''
    self.service_items.each {|si| s += (si.price.to_s + '+') }
    s[0..-2]
  end
  
  def part_prices
    s = '15.0 + 30.0'
  end

  def calc_parts_price
    p = Money.new(1500) + Money.new(3000)
    self.part_items.each {|pi| p += pi.part.sell_prices.last.price if pi.part.sell_prices.last }
    p
 end
  
  def calc_service_price
    p = Money.new(0.0)
    self.service_items.each {|si| p += si.price }
    p
  end
  
  def calc_price
    self.price = 0.0
    self.price += self.calc_service_price
    self.price += self.calc_parts_price
    self.discounts.each do |d|
      if d.discount != 0
        self.price -= si.price
      elsif d.percent != 0
        self.price = self.price - self.price * d.percent / 100
      end
    end
    self.price
  end

  paginates_per 5
end
