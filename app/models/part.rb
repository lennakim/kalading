# 配件
class Part
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  
  # 型号 
  field :number, type: String
  # 容量（机油）
  field :capacity, type: Integer, default: 1
  # 规格（升，个）
  field :spec, type: String
  # 价格
  field :price, type: Money, default: 0.0
  # 机油类型
  field :motoroil_type, type: Integer
  # 备注
  field :remark, type: String
  # 配件品牌
  belongs_to :part_brand
  # 配件类型
  belongs_to :part_type
  # 机油所属机油档次
  has_and_belongs_to_many :motoroil_group
  # 适用的车型年款
  has_and_belongs_to_many :auto_submodels
  # 网站价格信息
  has_many :urlinfos
  # 进货批次列表
  has_many :partbatches, dependent: :delete
  # 图文信息
  has_many :image_texts
  has_many :part_transfers

  attr_accessible :capacity, :number, :match_rule, :spec, :motoroil_type, :remark,
    :part_brand_id, :part_type_id,
    :auto_submodel_ids,
    :urlinfo_ids, :urlinfos_attributes, :price, :order_ids, :partbatch_ids,
    :motoroil_group_id,
    :image_text_ids, :image_texts_attributes
  
  accepts_nested_attributes_for :urlinfos, :allow_destroy => true
  
  MOTOROIL_TYPE = [0, 1, 2]
  MOTOROIL_TYPE_STRINGS = %w[mineral_oil semi_synthetic_oil fully_synthetic_oil]
  
  validates :number, uniqueness:  {case_sensitive: false}, presence: true
  validates :part_brand_id, presence: true
  validates :part_type_id, presence: true
  validates :capacity, presence: true
  
  def total_remained_quantity
    rq = 0
    self.partbatches.each do |pb|
      rq += pb.remained_quantity
    end
    rq
  end
  
  paginates_per 10
  
  def url_price
    ui = self.urlinfos.all.min {|x| x.price}
    ui ? ui.price : Money.new(0)
  end

  def ref_price
    return self.price if self.price != 0.0
    ui = self.urlinfos.all.min {|x| x.price}
    ui ? ui.price : Money.new(0)
  end
  
  def brand_and_number
    self.part_brand.name + ' ' + self.number
  end
  
  def matched_parts
    ref_asm = self.auto_submodels.find_by(data_source: 2)
    return [] if ref_asm.nil?
    parts = ref_asm.parts.where(part_type_id: self.part_type.id).excludes(id: self.id).select { |p| p.part_brand != self.part_brand }
    if ref_asm.part_rules.exists?
      pr = ref_asm.part_rules.find_by number: self.number
      return [] if pr.nil?
      parts.select do |p|
        pr1 = ref_asm.part_rules.find_by number: p.number
        pr1 && pr1.text == pr.text
      end
    else
      parts
    end
  end
  
  def as_json(options = nil)
    super except: [:price, :auto_submodel_ids, :updated_at, :spec, :created_at, :version, :order_ids, :part_brand_id, :part_type_id, :modifier_id, :capacity, :motoroil_type, :remark]
  end
  
  
end
