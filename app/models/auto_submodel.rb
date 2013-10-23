class AutoSubmodel
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  track_history :track_create   =>  true,    # track document creation, default is false
                :track_update   =>  true,     # track document updates, default is true
                :track_destroy  =>  true     # track document destruction, default is false


  paginates_per 5

  field :name, type: String
  field :motoroil_cap, type: Integer, default: 4
  field :engine_displacement, type: String
  field :remark, type: String
  field :engine_model, type: String
  field :service_level, type: String, default: 'maintain'
  field :match_rule, type: String
  
  index({ name: 1 })
        
  SERV_LEVEL = %w[maintain cantmaintain needconfirm]
  SERV_LEVEL.each do |name|
    def name.to_friendly
      I18n.t(self)
    end
  end

  belongs_to :auto_model
  has_and_belongs_to_many :parts
  has_many :autos, dependent: :delete
  has_many :orders
  embeds_many :pictures, :cascade_callbacks => true
  
  accepts_nested_attributes_for :pictures, :allow_destroy => true
  
  attr_accessible :name, :auto_model_id, :part_ids, :auto_ids, :motoroil_cap, :engine_displacement,
    :remark, :engine_model, :service_level, :match_rule, :picture_ids, :pictures_attributes

  validates :name, presence: true
  validates :auto_model_id, presence: true

  def self.search(k, v)
    if k && v && v.size > 0
      any_of({ k => /.*#{v}.*/i })
    else
      all
    end
  end
  
  def parts_by_type
    part_type_to_parts = {}
    self.parts.each do |part|
      part_type_to_parts[part.part_type] ||= []
      part_type_to_parts[part.part_type] << part
    end
    part_type_to_parts
  end

  paginates_per 30
end
