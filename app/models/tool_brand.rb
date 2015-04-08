class ToolBrand
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  attr_accessible :name

  validates :name, presence: true

  def can_be_deleted?
    # TODO: 需实现
    true
  end
end
