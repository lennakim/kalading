class AutoModel
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  track_history :track_create   =>  true,    # track document creation, default is false
                :track_update   =>  true,     # track document updates, default is true
                :track_destroy  =>  true     # track document destruction, default is false


  paginates_per 5

  field :name, type: String
  field :full_name_pinyin, type: String, default: ''
  attr_accessible :name, :auto_brand_id, :auto_submodels_attributes, :full_name_pinyin
  
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

  def full_name
    self.auto_brand.name + ' ' + self.name
  end

  def as_json(options = nil)
    h = super :except => [:updated_at, :created_at, :auto_brand_id, :version, :modifier_id, :name]
    h[:name] = self.auto_brand.name + ' ' + self.name
    h
  end
end
