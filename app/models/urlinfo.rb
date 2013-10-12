class Urlinfo
  include Mongoid::Document
  field :name, type: String
  field :url, type: String
  field :price, type: Money

  attr_accessible :price, :part_id, :url, :name

  belongs_to :part
end
