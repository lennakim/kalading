class AutoModel
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  track_history :track_create   =>  true,    # track document creation, default is false
                :track_update   =>  true,     # track document updates, default is true
                :track_destroy  =>  true     # track document destruction, default is false


  paginates_per 5

  field :name, type: String
  attr_accessible :name, :auto_brand_id, :auto_submodels_attributes
  
  belongs_to :auto_brand
  has_many :auto_submodels, dependent: :delete

  has_many :service_types
  
  validates :name, uniqueness:  {case_sensitive: false}, presence: true
  validates :auto_brand_id, presence: true
  
  index({ name: 1 })
        
  accepts_nested_attributes_for :auto_submodels, :allow_destroy => true
  
  def self.search(k, v)
    if k && v && v.size > 0
      any_of({ k => /.*#{v}.*/i })
    else
      all
    end
  end

end
