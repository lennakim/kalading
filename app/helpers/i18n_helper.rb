module I18nHelper
  # Usage:
  #   translate_collection_options(tool_type, :category)
  #   translate_collection_options(ToolType, :category, 'with_engineer')
  def translate_collection_options(object, method, value = nil)
    t("simple_form.options.#{object.model_name.underscore}.#{method}.#{value || object.send(method)}")
  end

  def translate_boolean(value)
    t("boolean.#{value}")
  end
end
