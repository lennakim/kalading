class Partbatch
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  
  field :quantity, type: Integer, default: 0
  field :price, type: Money
  field :remained_quantity, type: Integer, default: ->{ quantity }
  
  attr_accessible :price, :part_id, :quantity, :storehouse_id, :supplier_id, :remained_quantity, :modifier, :user_id
  
  validates :part_id, presence: true
  validates :storehouse_id, presence: true
  validates :supplier_id, presence: true
  validates :user_id, presence: true
  validates :quantity, inclusion: { in: 1..999999 }, presence: true
  validates :remained_quantity, inclusion: { in: 0..999999 }, presence: true
  
  validates :price, :allow_nil => false,
    :numericality => {
      :greater_than_or_equal_to => 0.0,
      :less_than_or_equal_to => 1000000
    }
  belongs_to :part
  belongs_to :storehouse
  belongs_to :supplier
  belongs_to :user
  
  if !Rails.env.importdata?
    track_history :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false
  end
  paginates_per 5
end
