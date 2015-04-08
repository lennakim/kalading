class ToolBrandsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @tool_brands = ToolBrand.all
  end

  def new
    @tool_brand = ToolBrand.new
  end

  def create
    @tool_brand = ToolBrand.new(params[:tool_brand])
    if @tool_brand.save
      redirect_to tool_brands_path
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @tool_brand.update_attributes(params[:tool_brand])
      redirect_to tool_brands_path
    else
      render action: 'edit'
    end
  end

  def destroy
    if @tool_brand.can_be_deleted?
      flash[:notice] = '删除成功'
      @tool_brand.destroy
    else
      flash[:error] = "#{@tool_brand.model_name.human} #{@tool_brand.name} 已使用，不能被删除"
    end
    redirect_to tool_brands_path
  end
end
