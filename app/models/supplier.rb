# 供应商
class Supplier
  include Mongoid::Document
  
  field :name, type: String
  field :address, type: String
  field :phone_num, type: String
  field :type, type: Integer, default: 0
  attr_accessible :name, :address, :phone_num, :type
  
  # 调货和盘库盈余不同于进货，没有供应商，所以使用特殊的供应商类型
  # 0: 普通，1: 调货，2: 盘库盈余
  TYPES = [0, 1, 2]
  TYPE_STRINGS = %w[general fake_supplier_for_transfer fake_supplier_for_yingyu]

  has_many :partbatches
end
