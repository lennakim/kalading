# 车型的第三级：年款
class AutoSubmodel
  include Mongoid::Document
  include Mongoid::Timestamps

  scope :without_cities, -> { without(:cities) }

  paginates_per 30

  field :name, type: String
  # 机油容量
  field :motoroil_cap, type: Float, default: 5
  # 引擎排量
  field :engine_displacement, type: String, default: ''
  # 备注
  field :remark, type: String
  # 发动机型号
  field :engine_model, type: String
  # 服务等级
  field :service_level, type: Integer, default: 1
  # 特殊的规则
  field :match_rule, type: String
  # 生产年代范围
  field :year_range, type: String, default: '2013-2014'
  # 曼牌数据
  field :name_mann, type: String
  # 曼牌数据
  field :year_mann, type: String
  # 全名拼音： 品牌+系列+年款。为了方便查找
  field :full_name_pinyin, type: String, default: ''
  field :full_name, type: String, default: ''
  field :oil_filter_oe, type: String
  field :fuel_filter_oe, type: String
  field :air_filter_oe, type: String

  # 0 for mann database
  # 1 for longfeng database
  # 2 for new data (20140309)
  # 3 for manually created or updated submodels
  # 4 for hidden submodels
  field :data_source, type: Integer, default: 0

  field :oil_filter_count, type: Integer, default: 0
  field :air_filter_count, type: Integer, default: 0
  field :cabin_filter_count, type: Integer, default: 0

  index({ oil_filter_count: 1, air_filter_count: 1, cabin_filter_count: 1 })
  index({ data_source: 1 })
  index({ full_name_pinyin: 1 })
  index({ service_level: 1 })

  SERV_LEVEL = [0, 1, 2]
  SERV_LEVEL_STRINGS = %w[cantmaintain maintain needconfirm]

  # 年款属于一个系列
  belongs_to :auto_model
  # 年款有很多适用的配件
  has_and_belongs_to_many :parts, after_add: :check_sanlv_add,  before_remove: :check_sanlv_removal
  # 年款可以属于某个城市
  has_and_belongs_to_many :cities
  has_many :autos
  # 年款有很多订单
  has_many :orders
  # 年款有很多知识库图片
  embeds_many :pictures, :cascade_callbacks => true
  # 年款有很多配件规则
  embeds_many :part_rules, :cascade_callbacks => true
  # 年款属于某个机油档次
  belongs_to :motoroil_group

  accepts_nested_attributes_for :pictures, :allow_destroy => true
  accepts_nested_attributes_for :part_rules, :allow_destroy => true

  attr_accessible :name, :auto_model, :auto_model_id, :part_ids, :city_ids, :auto_ids, :motoroil_cap, :engine_displacement,
    :remark, :engine_model, :service_level, :match_rule, :picture_ids, :pictures_attributes,
    :year_range, :name_mann, :full_name_pinyin, :full_name, :data_source, :oil_filter_oe, :fuel_filter_oe, :air_filter_oe,
    :year_mann, :part_rules_attributes, :motoroil_group_id

  attr_accessible :oil_filter_count, :air_filter_count, :cabin_filter_count

  validates :auto_model_id, presence: true
  validates_numericality_of :motoroil_cap, :greater_than_or_equal_to => 0.5, :less_than_or_equal_to => 100.0

  def self.search(k, v)
    if k && v && v.size > 0
      any_of({ k => /.*#{v}.*/i })
    else
      all
    end
  end

  PART_SORT_ORDER = { I18n.t(:engine_oil) => 0, I18n.t(:oil_filter) => 1, I18n.t(:air_filter) => 2, I18n.t(:cabin_filter) => 3, I18n.t(:pm25_filter) => 4, I18n.t(:battery) => 5 }

  def parts_includes_motoroil
    a = self.parts.asc(:number).sort_by {|x| x.part_brand.sort_factor.to_i }.select {|part| PART_SORT_ORDER.keys[1..-1].include?(part.part_type.name) && part.total_remained_quantity > 0 }
    if self.motoroil_group
      a += self.motoroil_group.ordered_parts.select {|p| p.total_remained_quantity > 0}
    end
    a
  end

  def parts_includes_motoroil_ignore_quantity
    a = self.parts.asc(:number).select {|part| PART_SORT_ORDER.keys[1..-1].include?(part.part_type.name) }
    if self.motoroil_group
      a += self.motoroil_group.ordered_parts
    end
    a
  end

  def parts_by_type
    parts_includes_motoroil.group_by {|part| part.part_type}.sort_by { |k, v| PART_SORT_ORDER[k.name] }
  end

  def parts_by_type_ignore_quantity
    parts_includes_motoroil_ignore_quantity.group_by {|part| part.part_type}.sort_by { |k, v| PART_SORT_ORDER[k.name] }
  end

  def cals_part_count(part)
    return 1 if part.part_type.name != I18n.t(:engine_oil)
    parts = self.parts_includes_motoroil_ignore_quantity.select {|p| p.part_type == part.part_type && p.part_brand == part.part_brand && p.spec == part.spec }.reject {|a| a.capacity <= 0}.sort {|a,b| b.capacity <=> a.capacity}
    mc = 0.0
    if self.motoroil_cap - self.motoroil_cap.floor >= 0.2
      total = self.motoroil_cap.floor + 1
    else
      total = self.motoroil_cap.floor
    end
    part_to_count = {}

    while mc < total
      p = nil
      parts.each do |pp|
        if pp.capacity.to_f <= (total - mc)
          p = pp
          mc += pp.capacity.to_f
          break
        end
      end
      if !p
        p = parts[0]
        mc += p.capacity.to_f
      end
      part_to_count[p] ||= 0
      part_to_count[p] += 1
    end

    part_to_count[part]? part_to_count[part] : 0
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

  def check_sanlv_add(p)
    if p.part_type.name == I18n.t(:oil_filter) && p.total_remained_quantity > 0
      self.update_attributes oil_filter_count: self.oil_filter_count + p.total_remained_quantity
    elsif p.part_type.name == I18n.t(:air_filter) && p.total_remained_quantity > 0
      self.update_attributes air_filter_count: self.air_filter_count + p.total_remained_quantity
    elsif p.part_type.name == I18n.t(:cabin_filter) && p.total_remained_quantity > 0
      self.update_attributes cabin_filter_count: self.cabin_filter_count + p.total_remained_quantity
    end
  end

  def check_sanlv_removal(p)
    if p.part_type.name == I18n.t(:oil_filter) && p.total_remained_quantity > 0
      self.update_attributes oil_filter_count: self.oil_filter_count - p.total_remained_quantity
    elsif p.part_type.name == I18n.t(:air_filter) && p.total_remained_quantity > 0
      self.update_attributes air_filter_count: self.air_filter_count - p.total_remained_quantity
    elsif p.part_type.name == I18n.t(:cabin_filter) && p.total_remained_quantity > 0
      self.update_attributes cabin_filter_count: self.cabin_filter_count - p.total_remained_quantity
    end
  end

  def on_part_inout(p, c)
    if p.part_type.name == I18n.t(:oil_filter)
      self.update_attributes oil_filter_count: self.oil_filter_count + c
    elsif p.part_type.name == I18n.t(:air_filter)
      self.update_attributes air_filter_count: self.air_filter_count + c
    elsif p.part_type.name == I18n.t(:cabin_filter)
      self.update_attributes cabin_filter_count: self.cabin_filter_count + c
    end
  end

  def sum_sanlv_store
    oil_filter_count = air_filter_count = cabin_filter_count = 0
    self.parts.each do |p|
      if p.total_remained_quantity > 0
        if p.part_type.name == I18n.t(:oil_filter)
          oil_filter_count = oil_filter_count + p.total_remained_quantity
        elsif p.part_type.name == I18n.t(:air_filter)
          air_filter_count = air_filter_count + p.total_remained_quantity
        elsif p.part_type.name == I18n.t(:cabin_filter)
          cabin_filter_count = cabin_filter_count + p.total_remained_quantity
        end
      end
    end
    if self.oil_filter_count != oil_filter_count
      self.update_attributes oil_filter_count: oil_filter_count
    end
    if self.air_filter_count != air_filter_count
      self.update_attributes air_filter_count: air_filter_count
    end
    if self.cabin_filter_count != cabin_filter_count
      self.update_attributes cabin_filter_count: cabin_filter_count
    end
  end

  def as_json(options = nil)
    opts = {:except => [:updated_at, :created_at, :version, :modifier_id, :auto_model_id, :part_ids, :city_ids, :remark, :engine_displacement, :match_rule, :name_mann, :data_source, :full_name_pinyin, :air_filter_oe, :fuel_filter_oe, :cabin_filter_oe, :oil_filter_oe, :service_level, :year_range, :motoroil_cap, :air_filter_count, :cabin_filter_count, :check_status, :engine_model, :motoroil_group_id, :oil_filter_count, :part_rules, :year_mann, :pictures]}
    h = super options.merge(opts) do |k, old_value, new_value|
      old_value + new_value
    end
    h[:brand] = self.auto_model.auto_brand.name
    h[:model] = self.auto_model.name
    h[:name] = self.name + ' '+ self.engine_displacement + ' ' + self.year_range
    h[:pictures] = self.pictures.map do |p|
      { url: p.p.url, size: p.p.size }
    end
    h
  end

  after_save do |asm|
    if asm.service_level == 1
      if asm.auto_model.service_level == 0
        asm.auto_model.update_attributes service_level: 1
      end
    else
      if asm.auto_model.service_level == 1
        if asm.auto_model.auto_submodels.where(service_level: 1).empty?
          asm.auto_model.update_attributes service_level: 0
        end
      end
    end
  end

  def models_and_parts_with_same_displacement(part_types)
    asms = self.auto_model.auto_submodels.where(data_source: 2, :engine_displacement => self.engine_displacement)
    return [asms.count, [1] * part_types.size ] if asms.count == 1
    [
      asms.count,
      (part_types.map do |t|
        asms.group_by {|asm| asm.parts.where(part_type: PartType.find_by(name: I18n.t(t))).asc(:number)[0]}.count
      end)
    ]
  end

  def served_engineers
    h = {}
    self.orders.any_in(:state => [5,6,7]).select {|o| !o.engineer.nil? }.group_by {|o| o.engineer }.each do |k, v|
      h[k] = v.count
    end
    h.sort_by {|a,b| b}.reverse.take(3).map {|e| {:name => e[0].name, :phone_num => e[0].phone_num}}
  end

  # api

  def model
    self.auto_model.name
  end

  def brand
    self.auto_model.auto_brand.name
  end

  def self.group_by_engine_displacement
    submodels = []
    hash = self.without_cities.group_by{ |e| e.engine_displacement }

    hash.each do |k, v|
      submodels << { engine_displacement: k, submodels: v }
    end

    submodels
  end

  def self.group_by_year_range
    submodels = []
    hash = self.without_cities.group_by{ |e| e.year_range }

    hash.each do |k, v|
      submodels << { year_range: k, submodels: v }
    end

    submodels
  end
end
