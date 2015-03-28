class ToolAssigneesController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :read, ToolAssignment

    params[:type] ||= 'engineer'
    if params[:type] == 'engineer'
      @assignees = Engineer.all
      @engineer_tools_total = ToolType.with_engineer.count
    elsif params[:type] == 'vehicle'
      @assignees = ServiceVehicle.all
      @vehicle_tools_total = ToolType.with_vehicle.count
    end
  end
end
