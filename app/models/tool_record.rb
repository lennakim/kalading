class ToolRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  field :engineer_name, type: String, default: ""
  field :tools_count, type:Hash, default: {}

  embeds_many :pictures, :cascade_callbacks => true
  accepts_nested_attributes_for :pictures, :allow_destroy => true
  
  attr_accessible :engineer_name, :tools_count,
    :picture_ids, :pictures_attributes
  
  validates :engineer_name, presence: true
  
  def as_json(options = nil)
    super :except => [:_id, :create_date, :tools_count]
  end
end
