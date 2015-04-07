class PartTransfer
  include Mongoid::Document
  include Mongoid::Timestamps
  
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
  attr_accessible :source_sh_id, :target_sh_id, :aasm_state, :quantity, :part_id

  aasm do
    state :part_transfering, :initial => true # 在途中
    state :part_transfer_finished # 完成

    event :begin do
      transitions from: :initialized, to: :pending do
        guard do
          true
        end
        after do
          generate_working_tag_number
          set_boarding_date
        end
      end

      transitions from: :pending, to: :finished do
        after do
          set_leaving_date
        end
      end
    end
  end
end
