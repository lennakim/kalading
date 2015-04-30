class ToolDetailsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    criteria = ToolDetail.order_by(:tool_type_id.asc, :tool_brand_id.asc)

    if params[:search].present?
      # '-'.bytes  #=> [45]
      # '－'.bytes #=> [239, 188, 141]
      values = params[:search].split(/-|－/).map(&:strip)
      tool_type_ids = ToolType.where(:name => /#{values[0]}/i).pluck(:id) if values[0].present?
      tool_brand_ids = ToolBrand.where(:name => /#{values[1]}/i).pluck(:id) if values[1].present?
      criteria = criteria.where(:tool_type_id.in => tool_type_ids)
      criteria = criteria.where(:tool_brand_id.in => tool_brand_ids) if tool_brand_ids.present?
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

    respond_to do |format|
      format.html { @tool_details = criteria.page(params[:page]).per(20) }
      format.json { render json: criteria.as_json }
    end
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
