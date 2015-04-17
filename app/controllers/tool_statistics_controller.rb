class ToolStatisticsController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :inspect, :tool_statistics

    if current_user.storehouse_admin?
      params[:city_id] = current_user.city_id
    end

    if params[:city_id].blank? && params[:tool_type_id].blank?
      flash.now[:error] = '请至少选择一个城市或工具'
      return
    end

    data = Tool.statistics_with_city_and_tool_type(params)
    @result = Tool.statistics_to_objects(data)
    @show_tool_brand = @result.first.try(:tool_brand).present?
  end

  def summary
    authorize! :inspect, :tool_summary

    tool_data = Tool.statistics_summary
    @result = Tool.statistics_to_objects(tool_data)
    @total = Tool.set_statistics_summary_total(@result)

    delivery_data = ToolDelivery.statistics_summary
    @delivery_result = Tool.statistics_to_objects(delivery_data)
  end
end
