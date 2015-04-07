class Evaluation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel

  field :desc,  type: String
  field :score, type: Integer, default: 5

  belongs_to :order

  def user_phone
    self.order.phone_num
  end
end