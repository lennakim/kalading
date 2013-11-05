class AutoBrand
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  track_history :track_create   =>  true,    # track document creation, default is false
                :track_update   =>  true,     # track document updates, default is true
                :track_destroy  =>  true     # track document destruction, default is false


  paginates_per 5

  field :name, type: String
  attr_accessible :name
  
  validates :name, uniqueness:  {case_sensitive: false}, presence: true
  
  index({ name: 1 })
        
  has_many :auto_models, dependent: :delete
  
  def self.search(k, v)
    if k && v && v.size > 0
      any_of({ k => /.*#{v}.*/i })
    else
      all
    end
  end
  
  def name_pinyin
    PinYin.of_string(self.name)[0]
  end
end
