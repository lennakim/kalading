class ServiceType
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :specific_auto_model, type: Boolean, default: false
  field :price, type: Money
  
  belongs_to :auto_model
  has_and_belongs_to_many :orders
  
  attr_accessible :name, :auto_model_id, :specific_auto_model, :price, :order_ids

  validates :name, uniqueness:  {case_sensitive: false}, presence: true
  validate :validate_auto_model

  def validate_auto_model
    if self.specific_auto_model
      errors.add(:auto_model, I18n.t(:auto_model_should_be_choosed) ) unless self.auto_model
    end
  end
end
