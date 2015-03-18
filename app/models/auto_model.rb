# 车型的第二级：系列
class AutoModel
  include Mongoid::Document
  include Mongoid::Timestamps

  paginates_per 20

  field :name, type: String
  field :name_pinyin, type: String, default: ''
  # 曼牌的原始数据
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

  attr_accessible :name, :auto_brand, :auto_brand_id, :auto_submodels_attributes, :name_pinyin, :name_mann, :data_source, :service_level
  
  # 系列属于一个品牌
  belongs_to :auto_brand
  # 系列有很多年款
  has_many :auto_submodels, dependent: :destroy
  # 系列可以有专属的服务项目
  has_many :service_types
  
  validates :name, presence: true
  validates :auto_brand_id, presence: true
  
  index({ name: 1 })
        
  accepts_nested_attributes_for :auto_submodels, :allow_destroy => true
  
  def self.search(k, v)
    if k && v && v.size > 0
      any_of({ k => /.*#{v}.*/i })
    else
      all
    end
  end

  def as_json(options = nil)
    super :except => [:updated_at, :created_at, :auto_brand_id, :version, :full_name_pinyin, :modifier_id, :name_mann, :name_pinyin, :data_source, :service_level]
  end
  
  def full_name
    self.auto_brand.name + ' ' + self.name
  end
  
  after_save do |am|
    if am.service_level == 1
      if am.auto_brand.service_level == 0
        am.auto_brand.update_attributes service_level: 1
      end
    else
      if am.auto_brand.service_level == 1
        if am.auto_brand.auto_models.where(service_level: 1).empty?
          am.auto_brand.update_attributes service_level: 0
        end
      end
    end
  end

end
