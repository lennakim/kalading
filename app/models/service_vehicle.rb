class ServiceVehicle
  include Mongoid::Document
  include Mongoid::Timestamps

  # 车牌号
  field :number, type: String

  belongs_to :city

  attr_accessible :number, :city_id

  validates :number, presence: true
  validates :city_id, presence: true
end
