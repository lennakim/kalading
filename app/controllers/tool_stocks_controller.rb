class ToolStocksController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    criteria = ToolStock
    if params[:remained_ceiling].present?
      criteria = criteria.where(:remained_count.lte => params[:remained_ceiling])
    end

    if params[:city_id].present?
      criteria = criteria.where(city_id: params[:city_id])
    end

    if params[:category].present?
      criteria = criteria.where(tool_type_category: params[:category])
    end

    @tool_stocks = criteria.page(params[:page]).per(20)
  end
end
