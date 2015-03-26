module ToolTypesHelper
  def tool_type_grouped_collection
    ToolType.all.group_by do |tool_type|
      translate_collection_options(tool_type, :category)
    end
  end
end
