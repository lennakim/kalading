module Concerns
  module ActsAsToolAssignee
    extend ActiveSupport::Concern

    included do
      field :current_tool_assignments_count, type: Integer, default: 0
      field :discarded_assignments_count, type: Integer, default: 0

      has_many :tool_assignments, as: :assignee
      accepts_nested_attributes_for :tool_assignments
    end

    module ClassMethods
      # 为新添加的字段设置默认值，以便查询。用后可删除
      #   ServiceVehicle.set_default_count!
      #   Engineer.set_default_count!
      def set_default_count!
        self.where(current_tool_assignments_count: nil).all.each do |o|
          o.current_tool_assignments_count = 0
          o.save!(validate: false)
        end

        self.where(discarded_assignments_count: nil).all.each do |o|
          o.discarded_assignments_count = 0
          o.save!(validate: false)
        end; nil
      end
    end
  end
end
