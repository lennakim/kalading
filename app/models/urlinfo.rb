class Urlinfo
  include Mongoid::Document
  field :name, type: String
  field :url, type: String
  field :price, type: Money

  attr_accessible :price, :part_id, :url, :name

  belongs_to :part
  
  def as_json(options = nil)
    h = super :except => [:price, :part_id, :_id]
    h[:price] = self.price.cents.to_f / 100.0
    h
  end
end
