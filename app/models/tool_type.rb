class ToolType
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, type: String, default: ""
  field :unit, type: String, default: I18n.t('default_unit')

  has_and_belongs_to_many :tool_records
  
  attr_accessible :name, :unit, :tool_record_ids

  validates :name, uniqueness: true, presence: true

  def as_json(options = nil)
    h = super :except => [:unit, :created_at, :updated_at, :tool_record_ids]
  end
end
