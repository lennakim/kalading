class Auto
  include Mongoid::Document
  include Mongoid::Timestamps
  field :car_location, type: String, default: I18n.t(:jing)
  field :car_num, type: String, default: ''
  field :next_maintain_time, type: String
  
  attr_accessible :car_location, :car_num, :vin, :user_ids, :auto_submodel_id, :next_maintain_time

  belongs_to :auto_submodel
  has_many :orders
  
  def self.search(k, v)
    if k && v && v.size > 0
      any_of({ k => /.*#{v}.*/i })
    else
      all
    end
  end

  paginates_per 40
end
