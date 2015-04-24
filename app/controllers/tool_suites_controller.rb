class ToolSuitesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @tool_suites = ToolSuite.all
  end

  def new
  end

  def create
    @tool_suite = ToolSuite.new(params[:tool_suite])
    if @tool_suite.save
      redirect_to tool_suites_path
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @tool_suite.update_attributes(params[:tool_suite])
      redirect_to tool_suites_path
    else
      render action: 'edit'
    end
  end

  def destroy
    if @tool_suite.can_be_deleted?
      flash[:notice] = '删除成功'
      @tool_suite.destroy
    else
      flash[:error] = "不能被删除"
    end
    redirect_to tool_suites_path
  end
end
