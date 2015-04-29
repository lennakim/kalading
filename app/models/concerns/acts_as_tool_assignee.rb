module Concerns
  module ActsAsToolAssignee
    extend ActiveSupport::Concern

    included do
      has_many :tool_assignments, as: :assignee
      has_many :tool_suite_assignments, as: :assignee

      accepts_nested_attributes_for :tool_assignments
    end

    def part_tool_assignments
      tool_assignments.where(tool_suite_assignment_id: nil)
    end
  end
end
