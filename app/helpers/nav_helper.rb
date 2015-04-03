module NavHelper
  def nav_active?(title, options = {})
    result = true

    if options[:action].present?
      result = params[:action] == options[:action]
    end

    params[:controller] == title.pluralize && result
  end

  # Usage:
  #   activatable_nav_link 'tool_type', tool_types_path
  #   activatable_nav_link 'tool_type', tool_types_path, link_text: '工具分类'
  def activatable_nav_link(title, url, options = {})
    link_text = options[:link_text] || title.camelize.constantize.model_name.human
    content_tag :li, link_to(link_text, url), :class => ("active" if nav_active?(title, options))
  end
end
