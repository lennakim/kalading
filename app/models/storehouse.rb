class Storehouse
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, type: String
  field :address, type: String
  field :phone_num, type: String
  
  attr_accessible :name, :address, :phone_num, :partbatch_ids, :partbatches_attributes
  

  has_many :partbatches
  accepts_nested_attributes_for :partbatches, :allow_destroy => true
  
  def to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << [I18n.t(:part_brand), I18n.t(:number), I18n.t(:part_type), I18n.t(:in_quantity), I18n.t(:remained_quantity), I18n.t(:batch_price), I18n.t(:partbatch_id), I18n.t(:partbatch_create_time), I18n.t(:comment) ]
      self.partbatches.sort {|x,y| x.part.part_brand.name <=> y.part.part_brand.name}.each do |pb|
        csv << [pb.part.part_brand.name, pb.part.number, pb.part.part_type.name, pb.quantity, pb.remained_quantity, pb.price, pb.id, I18n.l(pb.created_at), pb.comment]
      end
    end
  end

end
