# 行政区
class District
  include Mongoid::Document
  field :name, type: String
  
  #属于某个城市
  embedded_in :city
end
