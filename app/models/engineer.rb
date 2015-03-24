class Engineer < User
  include Mongoid::Document

  field :roles,    :type => Array, :default => [5]

  class << self
    # migrate所有角色为技师的User的type为Engineer, 用完可以删除
    def migrate_user_to_engineer
      User.where(roles: "5").update_all _type: 'Engineer'
    end
  end
end
