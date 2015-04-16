class ToolAssigneesController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :read, ToolAssignment

    params[:assignee_type] ||= 'engineer'
    if params[:assignee_type] == 'engineer'
      @model_class = Engineer
    elsif params[:assignee_type] == 'service_vehicle'
      @model_class = ServiceVehicle
    end
    criteria = @model_class

    if current_user.storehouse_admin?
      params[:city_id] = current_user.city_id
    end
    if params[:city_id].present?
      criteria = criteria.where(city_id: params[:city_id])
    end

    @assignees = criteria.page(params[:page]).per(20)
  end
end
