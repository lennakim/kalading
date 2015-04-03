class ToolTypesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    criteria = ToolType
    if params[:category].present?
      criteria = criteria.where(category: params[:category])
    end
    @tool_types = criteria.page(params[:page]).per(20)
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
    if @tool_type.can_be_deleted?
      flash[:notice] = '删除成功'
      @tool_type.destroy
    else
      flash[:error] = "#{@tool_type.name} 不能被删除"
    end
    redirect_to tool_types_path
  end
end
