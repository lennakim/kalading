class ServiceType
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :specific_auto_model, type: Boolean, default: false
  field :price, type: Money
  
  belongs_to :auto_model
  belongs_to :auto_brand
  has_and_belongs_to_many :orders
  
  attr_accessible :name, :auto_model_id, :specific_auto_model, :price, :order_ids, :auto_brand_id

  validate :validate_auto_model

  def validate_auto_model
    if self.specific_auto_model
      errors.add(:auto_model, I18n.t(:auto_model_should_be_choosed) ) unless self.auto_model || self.auto_brand
    end
  end
  
  def as_json(options = nil)
    h = super :except => [:auto_brand_id, :auto_model_id, :order_ids, :specific_auto_model, :updated_at, :created_at]
    h[:price] = self.price.to_f
    h
  end
end
