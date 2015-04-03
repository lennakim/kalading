module Concerns
  module ActsAsToolAssignee
    extend ActiveSupport::Concern

    included do
      field :current_tool_assignments_count, type: Integer, default: 0
      field :discarded_assignments_count, type: Integer, default: 0

      attr_accessor :to_be_assigned_tools_count

      has_many :tool_assignments, as: :assignee
    end

    def set_to_be_assigned_tools_count(total = nil)
      total ||= ToolType.with_assignee(self).count
      self.to_be_assigned_tools_count = total - current_tool_assignments_count
    end

    # 待分配的，包括分配后已损坏/丢失的
    def to_be_assigned_tool_types
      ToolType.with_assignee(self) - tool_assignments.current.normal.map(&:tool_type)
    end

    # 没有分配过的，不包括分配后已损坏/丢失的
    def unassigned_tool_types
      ToolType.with_assignee(self) - tool_assignments.current.map(&:tool_type)
    end

    # 将未分配的工具分配给技师或上门服务车辆
    def assign_tool_type(tool_type, assigner)
      tool_assignments.build(city_id: city.id, tool_type_id: tool_type.id, assigner_id: assigner.id).save
    end

    # 替换已损坏或丢失的工具，重新分配
    def reassign(assignment, assigner)
      assignment.approve_discarded(assigner) && assign_tool_type(assignment.tool_type, assigner)
    end

    def need_to_be_assigned?
      set_to_be_assigned_tools_count if self.to_be_assigned_tools_count.nil?

      self.to_be_assigned_tools_count > 0 || self.discarded_assignments_count > 0
    end

    def can_be_assigned_by_operator?(operator)
      if operator.storehouse_admin?
        operator.city == self.city
      else
        true
      end
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
