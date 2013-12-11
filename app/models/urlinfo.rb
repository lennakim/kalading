class Urlinfo
  include Mongoid::Document
  field :name, type: String
  field :url, type: String
  field :price, type: Money
  field :check_status, type: Integer, default: 0

  attr_accessible :price, :part_id, :url, :name, :check_status

  CHECK_STATUS = [0, 1]
  CHECK_STATUS_STRINGS = %w[unchecked checked]

  belongs_to :part
  
  def as_json(options = nil)
    h = super :except => [:price, :part_id, :_id]
    h[:price] = self.price.cents.to_f / 100.0
    h
  end
end
