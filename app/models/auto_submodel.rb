class AutoSubmodel
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  track_history :track_create   =>  true,    # track document creation, default is false
                :track_update   =>  true,     # track document updates, default is true
                :track_destroy  =>  true     # track document destruction, default is false


  paginates_per 5

  field :name, type: String
  field :motoroil_cap, type: Float, default: 4
  field :engine_displacement, type: String
  field :remark, type: String
  field :engine_model, type: String
  field :service_level, type: Integer, default: 0
  field :match_rule, type: String
  field :year_range, type: String
  field :check_status, type: Integer, default: 0
  field :name_mann, type: String
  
  index({ name: 1 })
  index({ service_level: 1 })

  SERV_LEVEL = [0, 1, 2]
  SERV_LEVEL_STRINGS = %w[maintain cantmaintain needconfirm]

  CHECK_STATUS = [0, 1]
  CHECK_STATUS_STRINGS = %w[unchecked checked]

  belongs_to :auto_model
  has_and_belongs_to_many :parts
  has_many :autos, dependent: :delete
  has_many :orders
  embeds_many :pictures, :cascade_callbacks => true
  
  accepts_nested_attributes_for :pictures, :allow_destroy => true
  
  attr_accessible :name, :auto_model_id, :part_ids, :auto_ids, :motoroil_cap, :engine_displacement,
    :remark, :engine_model, :service_level, :match_rule, :picture_ids, :pictures_attributes, :year_range, :name_mann

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
    self.parts.group_by {|part| part.part_type}
  end

  def full_name
    self.auto_model.auto_brand.name_with_jinkou + ' ' + self.auto_model.name + ' ' + self.name
  end
  
  def applicable_service_types
    sts = []
    ServiceType.all.each do |st|
      if st.specific_auto_model
        sts << st if self.auto_model == st.auto_model || self.auto_model.auto_brand == st.auto_brand
      else
        sts << st
      end
    end
    sts
  end
  
  def hengst_filters(filter_type)
    hengst_brand = PartBrand.find_or_create_by name: I18n.t(:hengst)
    filter_type = PartType.find_or_create_by name: I18n.t(filter_type)
    s = ''
    self.parts.where( part_brand_id: hengst_brand.id, part_type_id: filter_type.id ).each do |p|
      s += p.number + ';'
    end
    s
  end
  
  paginates_per 30
  
  def as_json(options = nil)
    super :except => [:updated_at, :created_at, :version, :modifier_id, :auto_model_id, :part_ids, :remark, :engine_displacement, :match_rule]
  end

end
