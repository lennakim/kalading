class Order
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  track_history :track_create   =>  true,    # track document creation, default is false
                :track_update   =>  true,     # track document updates, default is true
                :track_destroy  =>  true     # track document destruction, default is false

  
  field :state, type: String, default: 'unassigned'
  field :address, type: String
  field :phone_num, type: String
  field :buymyself, type: Boolean, default: false
  field :serve_date, type: Date
  field :price, type: Money
  
  belongs_to :customer, class_name: "User", inverse_of: :buy_orders
  belongs_to :engineer, class_name: "User", inverse_of: :serve_orders

  belongs_to :auto
  has_many :service_items, dependent: :delete
  has_many :discounts, dependent: :delete
  embeds_many :pictures, :cascade_callbacks => true
  embeds_many :part_items, :cascade_callbacks => true
  
  accepts_nested_attributes_for :pictures, :allow_destroy => true
  accepts_nested_attributes_for :service_items, :allow_destroy => true
  accepts_nested_attributes_for :auto, :allow_destroy => true
  accepts_nested_attributes_for :part_items, :allow_destroy => true

  attr_accessible :state, :address, :phone_num,:buymyself,:serve_date,
    :customer_id, :engineer_id, :auto_id,
    :service_item_ids, :service_items_attributes,
    :auto_id, :auto_attributes,
    :discount_ids, :discounts_attributes,
    :part_ids,
    :picture_ids, :pictures_attributes,
    :part_item_ids, :part_items_attributes
    
    
  STATES = %w[unassigned unscheduled scheduled serve_done handovered revisited]
  STATES.each do |name|
    def name.to_friendly
      I18n.t(self)
    end
  end

  before_save :calc_price
  
  def calc_price
    self.price = 0.0
    self.service_items.each {|si| self.price += si.price }
    self.discounts.each do |d|
      if d.discount != 0
        self.price -= si.price
      elsif d.percent != 0
        self.price = self.price - self.price * d.percent / 100
      end
    end
    self.part_items.each {|pi| self.price += pi.part.sell_prices.last.price if pi.part.sell_prices.last }
  end

  paginates_per 5
end
