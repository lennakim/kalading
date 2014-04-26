class Partbatch
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  
  field :quantity, type: Integer, default: 0
  field :price, type: Money
  field :remained_quantity, type: Integer, default: ->{ quantity }
  field :comment, type: String, default: ''
  
  attr_accessible :price, :part_id, :quantity, :storehouse_id, :supplier_id, :remained_quantity, :modifier, :user_id, :comment
  
  validates :part_id, presence: true
  validates :storehouse_id, presence: true
  validates :supplier_id, presence: true
  validates :user_id, presence: true
  validates :quantity, inclusion: { in: 1..999999 }, presence: true
  validates :remained_quantity, inclusion: { in: 0..999999 }, presence: true
  
  validates :price, :allow_nil => false,
    :numericality => {
      :greater_than_or_equal_to => 0.0,
      :less_than_or_equal_to => 1000000
    }
  belongs_to :part
  belongs_to :storehouse
  belongs_to :supplier
  belongs_to :user
  
  track_history :track_create   =>  true,    # track document creation, default is false
                :track_update   =>  true,     # track document updates, default is true
                :track_destroy  =>  true     # track document destruction, default is false

  after_create :on_create
  before_destroy :on_destroy
  
  def on_create
    return if self.part.part_type.name == I18n.t(:engine_oil)
    self.part.auto_submodels.each do |asm|
      asm.on_part_inout self.part, self.quantity
    end
  end

  def on_destroy
    return if self.part.part_type.name == I18n.t(:engine_oil)
    self.part.auto_submodels.each do |asm|
      asm.on_part_inout self.part, -self.remained_quantity
    end
  end

  paginates_per 5
end
