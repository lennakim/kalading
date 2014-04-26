class Part
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  track_history :track_create   =>  true,    # track document creation, default is false
                :track_update   =>  true,     # track document updates, default is true
                :track_destroy  =>  true     # track document destruction, default is false
  
  field :number, type: String
  field :capacity, type: Integer, default: 1
  field :spec, type: String
  field :price, type: Money, default: 0.0
  
  belongs_to :part_brand
  belongs_to :part_type
  has_and_belongs_to_many :motoroil_group
  has_and_belongs_to_many :auto_submodels
  has_many :urlinfos
  has_many :partbatches, dependent: :delete
  has_and_belongs_to_many :orders

  attr_accessible :capacity, :number, :match_rule, :spec,
    :part_brand_id, :part_type_id,
    :auto_submodel_ids,
    :urlinfo_ids, :urlinfos_attributes, :price, :order_ids, :partbatch_ids,
    :motoroil_group_id
  
  accepts_nested_attributes_for :urlinfos, :allow_destroy => true
  
  validates :number, uniqueness:  {case_sensitive: false}, presence: true
  #validates :stock_quantity, inclusion: { in: 0..999999 }, presence: true
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
  
  def as_json(options = nil)
    h = super :except => [:updated_at, :created_at, :auto_submodel_ids, :version, :modifier_id, :price, :part_brand_id, :part_type_id, :match_rule, :spec, :order_ids, :capacity]
    h[:brand_name] = self.part_brand.name
    h
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
    h = super except: [:price, :auto_submodel_ids, :updated_at, :spec, :created_at, :version, :order_ids, :part_brand_id, :part_type_id, :modifier_id, :capacity]
  end
  
  
end
