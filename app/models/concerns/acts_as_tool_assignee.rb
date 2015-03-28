module Concerns
  module ActsAsToolAssignee
    extend ActiveSupport::Concern

    included do
      field :tool_assignments_count, type: Integer, default: 0
      field :discarded_assignments_count, type: Integer, default: 0

      has_many :tool_assignments, as: :assignee
    end

    def assigned_normal_tool_types
      tool_assignments.where(discarded: false).map(&:tool_type)
    end

    def to_be_assigned_tool_types
      ToolType.with_assignee(self) - assigned_normal_tool_types
    end

    def assign_tool_type(tool_type, assigner)
      tool_assignments.build(city_id: city.id, tool_type_id: tool_type.id, assigner_id: assigner.id).save
    end
  end
end
