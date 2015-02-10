class Storehouse
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, type: String
  field :address, type: String
  field :phone_num, type: String
  field :comment, type: String
  
  attr_accessible :name, :address, :phone_num, :partbatch_ids, :partbatches_attributes, :city_id, :comment
  

  has_many :partbatches, dependent: :destroy
  has_many :users
  accepts_nested_attributes_for :partbatches, :allow_destroy => true
  belongs_to :city
  
  validates :city_id, presence: true
  validates :name, length: { in: 2..32 }, presence: true
  validates :address, length: { in: 2..128 }, presence: true
  validates :phone_num, length: { in: 7..32 }, presence: true
  
  def to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << [I18n.t(:part_brand), I18n.t(:part_number), I18n.t(:part_type), I18n.t(:in_quantity), I18n.t(:remained_quantity), I18n.t(:batch_price), I18n.t(:sell_price_history), I18n.t(:remark)]
      self.partbatches.group_by(&:part).to_a.sort_by {|x, y| x.number }.each do |part, partbatches|
        csv << [part.part_brand.name, part.number, part.part_type.name, partbatches.sum {|x| x.quantity}, partbatches.sum {|x| x.remained_quantity}, partbatches.first.price, part.ref_price, part.remark ]
      end
    end
  end

end
