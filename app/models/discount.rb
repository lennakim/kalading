class Discount
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  track_history :track_create   =>  true,    # track document creation, default is false
                :track_update   =>  true,     # track document updates, default is true
                :track_destroy  =>  true     # track document destruction, default is false

  field :name, type: String
  field :discount, type: Money, default: 0
  field :percent, type: Integer, default: 0
  field :expire_date, type: Date, default: Date.today.since(1.years)
  
  validates :name, uniqueness:  {case_sensitive: false}, presence: true
  validates :percent, inclusion: { in: 0..99 }, presence: true
  has_and_belongs_to_many :orders
  attr_accessible :name, :discount, :percent, :order_ids, :expire_date
end
