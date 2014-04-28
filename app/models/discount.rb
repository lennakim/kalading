class Discount
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :discount, type: Money, default: 0
  field :percent, type: Integer, default: 0
  field :expire_date, type: Date, default: Date.today.since(1.years)
  field :times, type: Integer, default: 1
  
  validates :times, inclusion: { in: 1..999999 }, presence: true
  validates :name, presence: true
  validates :percent, inclusion: { in: 0..100 }, presence: true
  has_and_belongs_to_many :orders
  attr_accessible :name, :discount, :percent, :order_ids, :expire_date, :times
  
  paginates_per 10
  
  def apply
    if discount.expire_date >= Date.today
      
    end
  end
end
