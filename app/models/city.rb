class City
  include Mongoid::Document
  field :name, type: String
  
  embeds_many :districts
  accepts_nested_attributes_for :districts, :allow_destroy => true
  
  def as_json(opts = nil)
    super except: [:_id]
  end
end
