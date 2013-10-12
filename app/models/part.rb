class Part
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  track_history :track_create   =>  true,    # track document creation, default is false
                :track_update   =>  true,     # track document updates, default is true
                :track_destroy  =>  true     # track document destruction, default is false

  field :number, type: String
  field :capacity, type: Integer, default: 1
  field :match_rule, type: String
  field :spec, type: String
  
  attr_accessible :capacity, :number, :match_rule, :spec,
    :part_brand_id, :part_type_id,
    :auto_submodel_ids,
    :urlinfo_ids, :urlinfos_attributes,
    :sell_prices_attributes, :sell_price_ids

  belongs_to :part_brand
  belongs_to :part_type
  has_and_belongs_to_many :auto_submodels
  has_many :urlinfos
  has_many :sell_prices
  has_many :partbatches
  
  accepts_nested_attributes_for :urlinfos, :allow_destroy => true
  accepts_nested_attributes_for :sell_prices, :allow_destroy => true
  
  validates :number, uniqueness:  {case_sensitive: false}, presence: true
  #validates :stock_quantity, inclusion: { in: 0..999999 }, presence: true
  validates :part_brand_id, presence: true
  validates :part_type_id, presence: true
  validates :capacity, presence: true
  
  def self.search(k, v)
    if k && v && v.size > 0
      any_of({ k => /.*#{v}.*/i })
    else
      all
    end
  end

  paginates_per 5
end
