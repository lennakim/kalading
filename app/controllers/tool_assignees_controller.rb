class ToolAssigneesController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :read, ToolAssignment

    params[:type] ||= 'engineer'
    if params[:type] == 'engineer'
      @assignees = Engineer.page(params[:page]).per(20)
      @tools_total = ToolType.with_engineer.count
    elsif params[:type] == 'vehicle'
      @assignees = ServiceVehicle.page(params[:page]).per(20)
      @tools_total = ToolType.with_vehicle.count
    end
  end
end
