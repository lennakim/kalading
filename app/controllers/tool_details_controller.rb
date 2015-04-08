class ToolDetailsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @tool_details = ToolDetail.page(params[:page]).per(20)
  end

  def new
    @existed_siblings = @tool_detail.existed_siblings_by_tool_type
  end

  def create
    @tool_detail = ToolDetail.new(params[:tool_detail])
    if @tool_detail.save
      redirect_to tool_details_path
    else
      @existed_siblings = @tool_detail.existed_siblings_by_tool_type
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @tool_detail.update_attributes(params[:tool_detail])
      redirect_to tool_details_path
    else
      render action: 'edit'
    end
  end

  def destroy
    if @tool_detail.can_be_deleted?
      flash[:notice] = '删除成功'
      @tool_detail.destroy
    else
      flash[:error] = "不能被删除"
    end
    redirect_to tool_details_path
  end
end
