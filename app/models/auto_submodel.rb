class PartRule
  include Mongoid::Document

  field :number, type: String
  field :text, type: String
  embedded_in :auto_submodel
end

class AutoSubmodel
  include Mongoid::Document
  include Mongoid::Timestamps

  paginates_per 5

  field :name, type: String
  field :motoroil_cap, type: Float, default: 5
  field :engine_displacement, type: String, default: ''
  field :remark, type: String
  field :engine_model, type: String
  field :service_level, type: Integer, default: 1
  field :match_rule, type: String
  field :year_range, type: String, default: '2013-2014'
  field :name_mann, type: String
  field :year_mann, type: String
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

  index({ data_source: 1 })
  index({ full_name_pinyin: 1 })
  index({ service_level: 1 })

  SERV_LEVEL = [0, 1, 2]
  SERV_LEVEL_STRINGS = %w[cantmaintain maintain needconfirm]

  belongs_to :auto_model
  has_and_belongs_to_many :parts, after_add: :check_sanlv_add,  before_remove: :check_sanlv_removal
  has_many :autos
  has_many :orders
  embeds_many :pictures, :cascade_callbacks => true
  embeds_many :part_rules, :cascade_callbacks => true
  belongs_to :motoroil_group

  accepts_nested_attributes_for :pictures, :allow_destroy => true
  accepts_nested_attributes_for :part_rules, :allow_destroy => true
  
  attr_accessible :name, :auto_model, :auto_model_id, :part_ids, :auto_ids, :motoroil_cap, :engine_displacement,
    :remark, :engine_model, :service_level, :match_rule, :picture_ids, :pictures_attributes,
    :year_range, :name_mann, :full_name_pinyin, :full_name, :data_source, :oil_filter_oe, :fuel_filter_oe, :air_filter_oe,
    :year_mann, :part_rules_attributes, :motoroil_group_id

  validates :auto_model_id, presence: true

  def self.search(k, v)
    if k && v && v.size > 0
      any_of({ k => /.*#{v}.*/i })
    else
      all
    end
  end
  
  PART_SORT_ORDER = { I18n.t(:engine_oil) => 0, I18n.t(:oil_filter) => 1, I18n.t(:air_filter) => 2, I18n.t(:cabin_filter) => 3 }

  def parts_includes_motoroil
    a = self.parts.asc(:number).select {|part| PART_SORT_ORDER.keys[1..-1].include?(part.part_type.name) && part.total_remained_quantity > 0 }
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
    parts = self.parts_includes_motoroil.select {|p| p.part_type == part.part_type && p.part_brand == part.part_brand && p.spec == part.spec }.reject {|a| a.capacity <= 0}.sort {|a,b| b.capacity <=> a.capacity}
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

  field :oil_filter_count, type: Integer, default: 0
  field :air_filter_count, type: Integer, default: 0
  field :cabin_filter_count, type: Integer, default: 0
  index({ oil_filter_count: 1, air_filter_count: 1, cabin_filter_count: 1 })

  attr_accessible :oil_filter_count, :air_filter_count, :cabin_filter_count

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

  paginates_per 30

  def as_json(options = nil)
    opts = {:except => [:updated_at, :created_at, :version, :modifier_id, :auto_model_id, :part_ids, :remark, :engine_displacement, :match_rule, :name_mann, :data_source, :full_name_pinyin, :air_filter_oe, :fuel_filter_oe, :cabin_filter_oe, :oil_filter_oe, :service_level, :year_range, :motoroil_cap]}
    h = super options.merge(opts) do |k, old_value, new_value|
      old_value + new_value
    end
    h[:name] = self.name + ' '+ self.engine_displacement + ' ' + self.year_range
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
  
end
