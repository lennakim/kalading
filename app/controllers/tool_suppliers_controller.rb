class ToolSuppliersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @tool_suppliers = ToolSupplier.all
  end

  def new
    @tool_supplier = ToolSupplier.new
  end

  def create
    @tool_supplier = ToolSupplier.new(params[:tool_supplier])
    if @tool_supplier.save
      redirect_to tool_suppliers_path
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @tool_supplier.update_attributes(params[:tool_supplier])
      redirect_to tool_suppliers_path
    else
      render action: 'edit'
    end
  end

  def destroy
    if @tool_supplier.can_be_deleted?
      flash[:notice] = '删除成功'
      @tool_supplier.destroy
    else
      flash[:error] = "#{@tool_supplier.model_name.human} #{@tool_supplier.name} 已使用，不能被删除"
    end
    redirect_to tool_suppliers_path
  end
end
