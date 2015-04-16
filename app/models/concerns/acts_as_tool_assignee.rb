module Concerns
  module ActsAsToolAssignee
    extend ActiveSupport::Concern

    included do
      has_many :tool_assignments, as: :assignee
      accepts_nested_attributes_for :tool_assignments
    end
  end
end
