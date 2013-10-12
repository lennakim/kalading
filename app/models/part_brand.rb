class PartBrand
  include Mongoid::Document
  include Mongoid::History::Trackable

  track_history :track_create   =>  true,    # track document creation, default is false
                :track_update   =>  true,     # track document updates, default is true
                :track_destroy  =>  true     # track document destruction, default is false

  field :name, type: String
  attr_accessible :name
  
  has_many :parts
 
  validates :name, uniqueness:  {case_sensitive: false}, presence: true
end
