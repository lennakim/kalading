# 配件类型
class PartType
  include Mongoid::Document
  
  field :name, type: String
  # 单位
  field :unit, type: String, default: I18n.t('default_unit')

  attr_accessible :name, :unit

  has_many :parts
  
  validates :name, uniqueness:  {case_sensitive: false}, presence: true
  
  scope :parts_by_type, ->(t){ where(name: t).parts.all }
  
  def allow_multi
    h = { I18n.t(:engine_oil) => true, I18n.t(:oil_filter) => false, I18n.t(:air_filter) => false, I18n.t(:cabin_filter) => true }
    return h[self.name]
  end

  def as_json(options = nil)
    super :except => [:_id, :unit]
  end
end
