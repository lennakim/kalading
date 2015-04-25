class PartTransfer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamp
  mongoid_userstamp user_model: 'User'
  
  field :quantity, type: Integer
  
  belongs_to :part
  belongs_to :source_sh, class_name: "Storehouse", inverse_of: :source_sh
  belongs_to :target_sh, class_name: "Storehouse", inverse_of: :target_sh
  
  validates :source_sh_id, presence: true
  validates :target_sh_id, presence: true
  validates :part_id, presence: true
  validates :quantity, inclusion: { in: 1..9999 }, presence: true
  validate :validate_shs

  def validate_shs
    errors.add(:source_sh, I18n.t(:source_target_sh_same) ) unless self.source_sh != self.target_sh
  end
  
  include AASM
  field :aasm_state
  attr_accessible :source_sh, :target_sh, :aasm_state, :quantity, :part_id, :part

  aasm do
    state :part_transfering, :initial => true # 在途中
    state :part_transfer_finished # 完成

    event :transfer do
      transitions from: :part_transfering, to: :part_transfering do
        guard do
          true
        end
        after do
          
        end
      end
    end
    
    event :finish do
      transitions from: :part_transfering, to: :part_transfer_finished, after: Proc.new {|*args| create_partbatch(*args)} do
        guard do
          true
        end
      end
    end
  end
    
  def create_partbatch current_user
    supplier = Supplier.find_or_create_by name: I18n.t(:fake_supplier_for_transfer), type: 1
    self.target_sh.partbatches.create! part_id: self.part.id,
      supplier_id: supplier.id,
      price: self.source_sh.partbatches.where(part: @part).desc(:created_at).first.price,
      quantity: self.quantity,
      remained_quantity: self.quantity,
      user_id: current_user.id
  end
  
  paginates_per 20
end
