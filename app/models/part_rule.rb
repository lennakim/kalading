# 针对某个年款的配件规则
class PartRule
  include Mongoid::Document

  field :number, type: String
  field :text, type: String
  embedded_in :auto_submodel
end
