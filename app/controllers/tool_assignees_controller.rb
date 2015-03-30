class ToolAssigneesController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :read, ToolAssignment

    params[:type] ||= 'engineer'
    if params[:type] == 'engineer'
      @assignees = Engineer.all.to_a
      @engineer_tools_total = ToolType.with_engineer.count
      @assignees.each { |assignee| assignee.set_to_be_assigned_tools_count(@engineer_tools_total) }
    elsif params[:type] == 'vehicle'
      @assignees = ServiceVehicle.all.to_a
      @vehicle_tools_total = ToolType.with_vehicle.count
      @assignees.each { |assignee| assignee.set_to_be_assigned_tools_count(@vehicle_tools_total) }
    end
  end
end
