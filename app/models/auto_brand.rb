class AutoBrand
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  if !Rails.env.importdata?
    track_history :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false
  end

  paginates_per 20

  field :name, type: String
  field :name_pinyin, type: String
  field :name_mann, type: String
  # 0 for mann database, 1 for longfeng database
  field :data_source, type: Integer, default: 0

  attr_accessible :name, :name_pinyin, :name_mann, :data_source
  
  validates :name, uniqueness:  {case_sensitive: false}, presence: true
  
  index({ name: 1 })
        
  has_many :auto_models, dependent: :delete
  
  def self.search(k, v)
    if k && v && v.size > 0
      any_of({ k => /.*#{v}.*/i })
    else
      all
    end
  end
  
  def name_with_jinkou
    n = self.name.split[0]
    n += ('(' + I18n.t(:jinkou) + ')') if self.name.index I18n.t(:jinkou)
    n
  end
  
  def as_json(options = nil)
    super :except => [:updated_at, :created_at, :version, :modifier_id, :name_mann, :name_pinyin]
  end

end
