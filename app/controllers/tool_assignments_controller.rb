class ToolAssignmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_assignee, only: [:check_batch_assignments, :batch_assign]
  load_and_authorize_resource except: [:check_batch_assignments, :batch_assign]

  def index
  end

  def check_batch_assignments
    authorize! :create, ToolAssignment

    @to_be_assigned = @assignee.to_be_assigned_tool_types
    @not_enough_stock = @to_be_assigned.reject do |tool_type|
      ToolStock.where(tool_type: tool_type, city: @assignee.city, :remained_count.gt => 0).exists?
    end
  end

  def batch_assign
    authorize! :create, ToolAssignment

    failed_list = @assignee.to_be_assigned_tool_types.reject do |tool_type|
      @assignee.assign_tool_type(tool_type, current_user)
    end

    if failed_list.blank?
      flash[:notice] = '分配成功'
    else
      flash[:error] = '分配失败'
    end
    redirect_to tool_assignees_path
  end

  private

    def find_assignee
      @assignee = params[:assignee_type].constantize.find(params[:assignee_id])
    end
end
