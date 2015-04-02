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
end
