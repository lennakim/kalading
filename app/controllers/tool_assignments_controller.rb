class ToolAssignmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_assignee, only: [:history, :prepare_for_assigning, :batch_assign]
  before_filter :find_assignment, only: [:break, :lose, :approve]
  before_filter :check_for_discarding, only: [:break, :lose]
  load_and_authorize_resource except: [:history, :prepare_for_assigning, :batch_assign]

  def index
    criteria = ToolAssignment

    if params[:status] == 'discarding'
      criteria = criteria.discarding
      template = 'discarding_list'
    elsif params[:status] == 'approved'
      criteria = criteria.approved
      template = 'approved_list'
    end

    if current_user.storehouse_admin?
      params[:city_id] = current_user.city_id
    end
    if params[:city_id].present?
      criteria = criteria.where(city_id: params[:city_id])
    end

    if params[:discarded_type].present?
      criteria = criteria.where(status: params[:discarded_type])
    end

    @assignments = criteria.page(params[:page]).per(20)

    if template.present?
      render template
    else
      render 'index'
    end
  end

  def history
    authorize! :read, ToolAssignment

    @tool_assignments = @assignee.tool_assignments.page(params[:page]).per(20)
  end

  def prepare_for_assigning
    authorize! :create, ToolAssignment

    # 在工具分配页面不显示已分配的工具
    @new_tool_assignments = []
  end

  def batch_assign
    authorize! :create, ToolAssignment

    attrs = params.try(:[], @assignee.model_name.underscore).try(:[], :tool_assignments_attributes).try(:values)

    # 去掉工具分配页面上被删除的工具行
    # 因为不使用tool_assignments_attributes=，所以_destroy要自己处理一下
    # _destroy: 1 or '1' or true or 'true' 都表示要删除，false or 'false' 表示不删除
    attrs = Array.wrap(attrs).select { |v| v[:_destroy].to_s == 'false' }

    if attrs.blank?
      # 在工具分配页面不显示已分配的工具
      @new_tool_assignments = []
      flash.now[:error] = '请添加要分配的工具'
      render action: 'prepare_for_assigning' and return
    end

    @new_tool_assignments, saved_count = ToolAssignment.batch_assign(attrs, @assignee, current_user)
    if saved_count > 0
      batch_quantity_sum = @new_tool_assignments.sum { |a| a.batch_quantity.to_i }
      if saved_count == batch_quantity_sum
        flash[:notice] = "成功分配#{saved_count}件工具给#{@assignee.model_name.human}#{@assignee.name}"
      else
        flash[:error] = "预计分配#{batch_quantity_sum}件工具给#{@assignee.model_name.human}#{@assignee.name}，实际分配#{saved_count}件。"
      end
      redirect_to tool_assignees_path(assignee_type: @assignee.model_name.underscore)
    else
      render action: 'prepare_for_assigning'
    end
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

  def approve
    if @assignment.approve_discarded(current_user)
      flash[:notice] = '批准丢/损申请成功'
    else
      flash[:error] = '批准丢/损申请失败'
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
