class ToolTypesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @tool_types = ToolType.page(params[:page]).per(20)
  end

  def new
    @tool_type = ToolType.new
  end

  def create
    @tool_type = ToolType.new(params[:tool_type])
    if @tool_type.save
      redirect_to tool_types_path
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @tool_type.update_attributes(params[:tool_type])
      redirect_to tool_types_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @tool_type.destroy
    redirect_to tool_types_path
  end
end
