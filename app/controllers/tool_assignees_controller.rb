class ToolAssigneesController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :read, ToolAssignment

    params[:assignee_type] ||= 'engineer'
    if params[:assignee_type] == 'engineer'
      criteria = Engineer
    elsif params[:assignee_type] == 'service_vehicle'
      criteria = ServiceVehicle
    end
    @tools_total = ToolType.with_assignee(criteria).count

    if params[:city_id].present?
      criteria = criteria.where(city_id: params[:city_id])
    end

    if params[:assignment_type] == 'assigned'
      criteria = criteria.where(current_tool_assignments_count: @tools_total,
                                discarded_assignments_count: 0)
    elsif params[:assignment_type] == 'unassigned'
      criteria = criteria.or({ :current_tool_assignments_count.lt => @tools_total },
                             { :discarded_assignments_count.gt => 0 })
    end

    @assignees = criteria.page(params[:page]).per(20)
  end
end
