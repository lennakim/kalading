# 车型的第一级：品牌
class AutoBrand
  include Mongoid::Document
  include Mongoid::Timestamps

  paginates_per 20

  field :name, type: String
  field :name_pinyin, type: String
  field :name_mann, type: String
  # 0 for mann database
  # 1 for longfeng database
  # 2 for new data (20140309)
  # 3 for manually created or updated submodels
  # 4 for hidden submodels
  field :data_source, type: Integer, default: 2
  index({ data_source: 1 })

  field :service_level, type: Integer, default: 0
  index({ service_level: 1 })

  validates :name, presence: true
  
  attr_accessible :name, :name_pinyin, :name_mann, :data_source, :service_level, :picture_attributes
  
  index({ name: 1 })
  # 品牌有很多系列
  has_many :auto_models, dependent: :destroy
  embeds_one :picture, :cascade_callbacks => true
  accepts_nested_attributes_for :picture, :allow_destroy => true

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
    opts = {:except => [:updated_at, :created_at, :version, :modifier_id, :name_mann, :data_source, :service_level, :picture]}
    h = super options.merge(opts) do |k, old_value, new_value|
      old_value + new_value
    end
    h[:logo] = self.picture.p.url if self.picture
    h[:initial] = self.name_pinyin.chr.upcase
    h
  end

end
