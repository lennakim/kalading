class ToolBatchesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @tool_batches = ToolBatch.page(params[:page]).per(20)
  end

  def new
    @tool_batch = ToolBatch.new
  end

  def create
    @tool_batch = ToolBatch.new(params[:tool_batch])
    @tool_batch.operator = current_user
    @tool_batch.city = current_user.city if current_user.storehouse_admin?

    if @tool_batch.save
      redirect_to tool_batches_path
    else
      render action: 'new'
    end
  end
end
