class City
  include Mongoid::Document
  field :name, type: String
  field :order_capacity, type: Integer, default: 9999
  field :area_code, type: String, default: ''
  field :opened, type: Boolean, default: false
  
  validates :order_capacity, inclusion: { in: 1..9999 }, presence: true
  validates :name, presence: true
  validates :area_code, uniqueness: true, presence: true
  
  embeds_many :districts
  accepts_nested_attributes_for :districts, :allow_destroy => true
  has_many :orders
  has_many :storehouses
  has_many :users
  has_many :complaints
  has_and_belongs_to_many :auto_submodels
  has_and_belongs_to_many :notifications
  
  def as_json(opts = nil)
    super except: [:order_capacity, :area_code, :opened, :auto_submodel_ids, :notification_ids, :complaint_ids]
  end
end
