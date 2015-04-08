# 仓库，点部
class Storehouse
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  # 地址
  field :address, type: String
  # 联系人电话
  field :phone_num, type: String
  # 备注
  field :comment, type: String
  # 类型，点部或仓库
  field :type, type: Integer, default: 0

  attr_accessible :name, :address, :phone_num, :partbatch_ids, :partbatches_attributes, :city_id, :comment, :type

  # 仓库有很多配件批次
  has_many :partbatches, dependent: :destroy
  # 点部有很多技师
  has_many :users
  accepts_nested_attributes_for :partbatches, :allow_destroy => true
  # 所在城市
  belongs_to :city
  TYPES = [0, 1]
  TYPE_STRINGS = %w[dianbu storehouse]
  validates :city_id, presence: true
  validates :name, length: { in: 2..32 }, presence: true
  validates :address, length: { in: 2..128 }, presence: true
  validates :phone_num, length: { in: 7..32 }, presence: true

  def to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << [I18n.t(:part_brand), I18n.t(:part_number), I18n.t(:part_type), I18n.t(:in_quantity), I18n.t(:remained_quantity), I18n.t(:remark)]
      self.partbatches.group_by(&:part).to_a.sort_by {|x, y| x.number }.each do |part, partbatches|
        csv << [part.part_brand.name, part.number, part.part_type.name, partbatches.sum {|x| x.quantity}, partbatches.sum {|x| x.remained_quantity}, part.remark ]
      end
    end
  end

end
