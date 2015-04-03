class ServiceVehicle
  include Mongoid::Document
  include Mongoid::Timestamps
  include Concerns::ActsAsToolAssignee

  # 车牌号
  field :number, type: String

  belongs_to :city

  attr_accessible :number, :city_id

  validates :number, presence: true
  validates :city_id, presence: true

  alias_method :name, :number

  def can_be_deleted?
    !ToolAssignment.where(assignee_id: self.id, assignee_type: self.model_name).exists?
  end
end
