class ServiceType
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :specific_auto_model, type: Boolean, default: false
  
  has_many :sell_prices
  has_many :service_items
  
  belongs_to :auto_model
  
  attr_accessible :name, :sell_price_ids, :sell_prices_attributes, :auto_model_id, :specific_auto_model
  validates :name, uniqueness:  {case_sensitive: false}, presence: true

  accepts_nested_attributes_for :sell_prices, :allow_destroy => true
  
  validate :validate_auto_model

  def validate_auto_model
    if self.specific_auto_model
      errors.add(:auto_model, I18n.t(:auto_model_should_be_choosed) ) unless self.auto_model
    end
  end

  def as_json(options = nil)
    { price: sell_prices.last.price.to_s }
  end

end
