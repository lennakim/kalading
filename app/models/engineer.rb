class Engineer < User
  include Mongoid::Document

  field :roles, type: Array, default: ["5"]

  # 主管 资深 实习？
  field :level, type: Integer, default: 0

  # 休息 工作 请假 培训
  field :status, type: Integer, default: 0

  # 工牌
  field :work_tag_number, type: String
  validates :work_tag_number, uniqueness: true, presence: true

  # 所配车辆 TODO
  #

  # 培训技能

  attr_accessible :work_tag_number

  class << self
    # migrate所有角色为技师的User的type为Engineer, 用完可以删除
    def migrate_user_to_engineer
      User.where(roles: "5").update_all _type: 'Engineer'
    end
  end

end
