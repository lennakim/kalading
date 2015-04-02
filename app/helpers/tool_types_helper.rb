module ToolTypesHelper
  def tool_type_grouped_collection
    ToolType.all.group_by do |tool_type|
      translate_collection_options(tool_type, :category)
    end
  end

  def tool_type_category_collection
    ToolType::CATEGORIES.map do |category|
      [translate_collection_options(ToolType, :category, category), category]
    end
  end

  def tool_assignee_type_collection
    ['engineer', 'service_vehicle'].map do |type|
      [type.camelize.constantize.model_name.human, type]
    end
  end

  def tool_assignment_type_collection
    ['assigned', 'unassigned'].map do |type|
      [t("views.modules.tool_management.#{type}"), type]
    end
  end
end
