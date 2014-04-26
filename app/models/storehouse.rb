class Storehouse
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, type: String
  field :address, type: String
  field :phone_num, type: String
  
  attr_accessible :name, :address, :phone_num, :partbatch_ids, :partbatches_attributes
  

  has_many :partbatches, dependent: :destroy
  accepts_nested_attributes_for :partbatches, :allow_destroy => true
  
  def to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << [I18n.t(:part_brand), I18n.t(:number), I18n.t(:part_type), I18n.t(:in_quantity), I18n.t(:remained_quantity), I18n.t(:batch_price) ]
      self.partbatches.group_by(&:part).to_a.sort_by {|x, y| x.number }.each do |part, partbatches|
        csv << [part.part_brand.name, part.number, part.part_type.name, partbatches.sum {|x| x.quantity}, partbatches.sum {|x| x.remained_quantity}, partbatches.first.price ]
      end
    end
  end

end
