class ToolBatchesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource except: [:bulk_create]

  def index
    criteria = ToolBatch.order_by(:created_at.desc)
    if params[:date_from].present?
      date_from = Date.parse(params[:date_from]).beginning_of_day
      criteria = criteria.where(:created_at.gte => date_from)
    end

    if params[:date_to].present?
      date_to = Date.parse(params[:date_to]).end_of_day
      criteria = criteria.where(:created_at.lte => date_to)
    end

    if params[:tool_type_id].present?
      criteria = criteria.where(tool_type_id: params[:tool_type_id])
    end

    if params[:tool_brand_id].present?
      criteria = criteria.where(tool_brand_id: params[:tool_brand_id])
    end

    if params[:tool_supplier_id].present?
      criteria = criteria.where(tool_supplier_id: params[:tool_supplier_id])
    end

    @tool_batches = criteria.page(params[:page]).per(20)
  end

  def new
  end

  def bulk_create
    authorize! :create, ToolBatch

    if params[:tool_batches].blank?
      render action: 'new' and return
    end

    @saved_tool_batches = []
    @new_tool_batches = []
    params[:tool_batches].each do |attrs|
      tool_batch = ToolBatch.new(attrs)
      tool_batch.operator = current_user
      if tool_batch.save
        @saved_tool_batches << tool_batch
      else
        @new_tool_batches << tool_batch
      end
    end

    if @new_tool_batches.empty?
      redirect_to tool_batches_path
    else
      render action: 'new'
    end
  end
end
