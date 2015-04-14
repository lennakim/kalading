class ToolAssignmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_assignee, only: [:check_batch_assignments, :batch_assign]
  before_filter :find_assignment, only: [:break, :lose]
  before_filter :check_for_discarding, only: [:break, :lose]
  load_and_authorize_resource except: [:check_batch_assignments, :batch_assign]

  def index
    criteria = ToolAssignment
    if params[:status] == 'discarded'
      criteria = criteria.where(discarded: true)
    end

    if params[:city_id].present?
      criteria = criteria.where(city_id: params[:city_id])
    end

    if params[:category].present?
      criteria = criteria.where(tool_type_category: params[:category])
    end

    if params[:discarded_type].present?
      criteria = criteria.where(status: params[:discarded_type])
    end

    @assignments = criteria.page(params[:page]).per(20)
  end

  def check_batch_assignments
    authorize! :create, ToolAssignment

    @to_be_assigned = @assignee.to_be_assigned_tool_types
    @not_enough_stock = []
  end

  def batch_assign
    authorize! :create, ToolAssignment

    failed_list = @assignee.unassigned_tool_types.reject do |tool_type|
      @assignee.assign_tool_type(tool_type, current_user)
    end

    @assignee.tool_assignments.discarding.each do |assignment|
      failed_list << assignment.tool_type if !@assignee.reassign(assignment, current_user)
    end

    if failed_list.blank?
      flash[:notice] = '分配成功'
    else
      # 工具 xxx, xxx 由于库存不足，给#{@assignee.model_name.human}#{@assignee.name}分配失败
      flash[:error] = '分配失败'
    end
    redirect_to tool_assignees_path
  end

  def break
    if @assignment.mark_as_broken(current_user)
      flash[:notice] = '标为损坏成功'
    else
      flash[:error] = '标为损坏失败'
    end

    redirect_to :back
  end

  def lose
    if @assignment.mark_as_lost(current_user)
      flash[:notice] = '标为丢失成功'
    else
      flash[:error] = '标为丢失失败'
    end

    redirect_to :back
  end

  private

    def find_assignee
      @assignee = params[:assignee_type].constantize.find(params[:assignee_id])
    end

    def find_assignment
      @assignment = ToolAssignment.find(params[:id])
    end

    def check_for_discarding
      if current_user.engineer? && @assignment.assignee_type == 'Engineer' &&
        @assignment.assignee != current_user
        flash[:error] = '没有权限'
        redirect_to :back
      end
    end
end
