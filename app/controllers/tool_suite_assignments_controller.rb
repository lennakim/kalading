class ToolSuiteAssignmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_assignee, only: [:new, :create]

  def new
    authorize! :create, ToolAssignment

    @tool_suite_assignment = ToolSuiteAssignment.new
  end

  def create
    authorize! :create, ToolAssignment

    @tool_suite_assignment = ToolSuiteAssignment.new(params[:tool_suite_assignment])
    if @tool_suite_assignment.assign(@assignee, current_user)
      redirect_to tool_assignees_path(assignee_type: @assignee.model_name.underscore)
    else
      render action: 'new'
    end
  end

  private

    def find_assignee
      @assignee = params[:assignee_type].constantize.find(params[:assignee_id])
    end
end
