class Tag
  include Mongoid::Document
  field :name, type: String
  field :type, type: Integer, default: 0
  
  TYPES = [0, 1, 2]
  TYPE_STRINGS = %w[none complaint evaluation]

end
