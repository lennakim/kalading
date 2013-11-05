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
  field :price, type: Money, default: 0.0
  
  belongs_to :part_brand
  belongs_to :part_type
  has_and_belongs_to_many :auto_submodels
  has_many :urlinfos
  has_many :partbatches
  has_and_belongs_to_many :orders

  attr_accessible :capacity, :number, :match_rule, :spec,
    :part_brand_id, :part_type_id,
    :auto_submodel_ids,
    :urlinfo_ids, :urlinfos_attributes, :price, :order_ids
  
  accepts_nested_attributes_for :urlinfos, :allow_destroy => true
  
  validates :number, uniqueness:  {case_sensitive: false}, presence: true
  #validates :stock_quantity, inclusion: { in: 0..999999 }, presence: true
  validates :part_brand_id, presence: true
  validates :part_type_id, presence: true
  validates :capacity, presence: true
  
  def self.search(k, v)
    if k && v && v.size > 0
      vv = v.scan(/[A-Z,a-z]+|\d+/i).join '.*'
      any_of({ k => /.*#{vv}.*/i })
    else
      all
    end
  end

  def total_remained_quantity
    rq = 0
    self.partbatches.each do |pb|
      rq += pb.remained_quantity
    end
    rq
  end
  paginates_per 5
end
