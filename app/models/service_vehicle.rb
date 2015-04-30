class ServiceVehicle
  include Mongoid::Document
  include Mongoid::Timestamps
  include Concerns::ActsAsToolAssignee

  # 车牌号
  field :number, type: String
  field :city_name, type: String

  index({ city_id: 1, number: 1 })
  index({ number: 1 })

  belongs_to :city

  attr_accessible :number, :city_id

  validates :number, presence: true
  validates :city_id, presence: true

  before_create :set_city_name

  alias_method :name, :number

  def set_city_name
    self.city_name = city.try(:name)
  end

  def can_be_deleted?
    !ToolAssignment.where(assignee_id: self.id, assignee_type: self.model_name).exists?
  end
end
