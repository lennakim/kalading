class Supplier
  include Mongoid::Document
  include Mongoid::History::Trackable

  if !Rails.env.importdata?
    track_history :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false
  end
  
  field :name, type: String
  field :address, type: String
  field :phone_num, type: String
  
  attr_accessible :name, :address, :phone_num
  
  has_many :partbatches
end
