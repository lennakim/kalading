class ImageText
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title, type: String, default: ""
  field :tags, type: Array
  
  embeds_many :pictures, :cascade_callbacks => true
  belongs_to :part
  
  accepts_nested_attributes_for :pictures, :allow_destroy => true
  
  attr_accessible :title, :tags,
    :picture_ids, :pictures_attributes,
    :part_id
  
  validates :title, presence: true

  def as_json(options = nil)
    h = super :except => [:_id, :created_at, :updated_at]
  end
end
