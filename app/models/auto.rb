class Auto
  include Mongoid::Document
  include Mongoid::Timestamps
  field :number, type: String
  field :vin, type: String
  
  validates :number, uniqueness:  {case_sensitive: false}, presence: true
  attr_accessible :number, :vin, :user_ids, :auto_submodel_id
  
  has_and_belongs_to_many :users
  belongs_to :auto_submodel
  has_many :orders
  
  def self.search(k, v)
    if k && v && v.size > 0
      any_of({ k => /.*#{v}.*/i })
    else
      all
    end
  end

  paginates_per 40
end
