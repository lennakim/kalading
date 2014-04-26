class District
  include Mongoid::Document
  field :name, type: String
  
  embedded_in :city
end
