module ToolTypesHelper
  def tool_type_category_collection
    ToolType::CATEGORIES.map do |category|
      [translate_collection_options(ToolType, :category, category), category]
    end
  end

  def tool_assignee_type_collection
    %w[engineer service_vehicle].map do |type|
      [type.camelize.constantize.model_name.human, type]
    end
  end

  def tool_assignment_type_collection
    %w[assigned unassigned].map do |type|
      [t("views.modules.tool_management.#{type}"), type]
    end
  end

  def tool_assignment_discarded_type_collection
    %w[broken lost].map do |type|
      [translate_collection_options(ToolAssignment, :status, type), type]
    end
  end
end
