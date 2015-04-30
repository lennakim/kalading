module Concerns
  module ActsAsToolAssignee
    extend ActiveSupport::Concern

    included do
      has_many :tool_assignments, as: :assignee
      has_many :tool_suite_assignments, as: :assignee

      accepts_nested_attributes_for :tool_assignments
    end

    def individual_tool_assignments
      tool_assignments.where(tool_suite_assignment_id: nil)
    end

    # 重新整编某个技师或上门服务车辆的工具
    def organize_tools_by_suite
      suite_assign = tool_suite_assignments.first
      individual_normal_assigns = individual_tool_assignments.normal
      grouped_tool_assigns = individual_normal_assigns.group_by(&:tool_type_id)

      if grouped_tool_assigns.size == 0
        suite_assign.tool_suite_inventory.correct_completeness if suite_assign.present?
        return
      end

      if suite_assign.nil?
        assigner = individual_normal_assigns.first.assigner
        suite_assign = ToolSuiteInventory.assign_empty_inventory(self, assigner)
      end

      suite_assign.tool_suite_inventory.lacking_tools.each do |tool_type_id, suite_item|
        quantity = suite_item.quantity
        assigns = Array.wrap(grouped_tool_assigns[tool_type_id]).slice(0, quantity)
        assigns.each { |assign| assign.add_to_suite(suite_assign) }
      end

      suite_assign.tool_suite_inventory.correct_completeness
    end

  end
end
