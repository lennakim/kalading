module ToolsHelper
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

  def tool_assignment_discarded_type_collection
    %w[broken lost].map do |type|
      [translate_collection_options(ToolAssignment, :status, type), type]
    end
  end

  def display_delivery_statistics(data, tool_type_category)
    data.map do |item|
      count = item.send("#{tool_type_category}_suites_count")
      "#{item.city.name}#{count}套" if count > 0
    end.compact.join('，')
  end
end
