class Evaluation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :desc,  type: String
  field :score, type: Integer, default: 5

  belongs_to :order
end