class ToolRecordValidator < ActiveModel::Validator
  def validate(record)
    if ToolRecord.where(engineer_name: record.engineer_name, create_date: record.create_date).exists?
      record.errors[:engineer_name] << 'current engineer has commited tool check record today'
    end
  end
end

class ToolRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  field :engineer_name, type: String, default: ""
  field :create_date, type: Date, default: lambda { Date.today }
  field :tools_count, type:Hash, default: {}

  has_and_belongs_to_many :tool_types
  embeds_many :pictures, :cascade_callbacks => true
  accepts_nested_attributes_for :pictures, :allow_destroy => true
  
  attr_accessible :engineer_name, :create_date, :tools_count,
    :tool_type_ids, :picture_ids, :pictures_attributes
  
  validates :engineer_name, presence: true
  validates_with ToolRecordValidator
  
  def as_json(options = nil)
    super :except => [:_id, :create_date, :tools_count, :tool_type_ids]
  end
end
