class PartType
  include Mongoid::Document
  include Mongoid::History::Trackable

  if !Rails.env.importdata?
    track_history :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false
  end
  
  field :name, type: String
  field :unit, type: String, default: I18n.t('default_unit')

  attr_accessible :name, :unit

  has_many :parts
  
  validates :name, uniqueness:  {case_sensitive: false}, presence: true
  
  scope :parts_by_type, ->(t){ where(name: t).parts.all }
  
end
