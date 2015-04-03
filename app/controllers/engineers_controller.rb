class EngineersController < ApplicationController
  before_filter :authenticate_user!
  inherit_resources
  load_resource only: [:tool_assignments]

  def update
    @engineer = Engineer.find(params[:id])
    params[:engineer][:roles].reject!(&:blank?)
    respond_to do |format|
      if @engineer.update_attributes(params[:engineer])
        format.html { redirect_to user_path(@engineer), notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @engineer.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    create!{ engineers_path }
  end

  def tool_assignments
    authorize! :read, ToolAssignment

    @assignee = @engineer
    @assignments = @assignee.tool_assignments.current
    render 'tool_assignments/list_of_assignee'
  end

  def my_tool_assignments
    authorize! :read_and_discard, :my_tool_assignments

    @assignee = current_user
    @assignments = @assignee.tool_assignments.current
    render 'tool_assignments/list_of_assignee'
  end
end
