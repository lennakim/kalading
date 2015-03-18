# 客户类别
class UserType
  include Mongoid::Document
  field :name, type: String
end
