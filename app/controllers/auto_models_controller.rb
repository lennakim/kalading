class AutoModelsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  before_filter :set_default_operator
  # API test for Jason
  load_and_authorize_resource :except => [:show]
  
  # GET /auto_models
  # GET /auto_models.json
  def index
    if params[:auto_brand_id] && params[:auto_brand_id] != ''
      @auto_models = AutoModel.where(data_source: 2, auto_brand_id: params[:auto_brand_id]).asc(:name)
    else
      @auto_models = AutoModel.where(data_source: 2).asc(:name)
    end
    
    respond_to do |format|
      format.html {
        @auto_models = @auto_models.page params[:page]
      }
      format.js
      format.json {
        render json: @auto_models
      }
    end
  end

  # GET /auto_models/1
  # GET /auto_models/1.json
  def show
    params[:data_source] ||= 2
    @auto_model = AutoModel.find(params[:id])
    respond_to do |format|
      format.html {
        @auto_submodels = @auto_model.auto_submodels.where(data_source: params[:data_source]).asc(:name).page params[:page]
      }
      format.js {
        @auto_submodels = @auto_model.auto_submodels.where(data_source: params[:data_source]).asc(:name).page params[:page]
      }
      format.json {
        # Only show maintainable asms on web site
        if params[:pm25].blank?
          render json: @auto_model.auto_submodels.where(data_source: 2, service_level: 1).where(:oil_filter_count.gt => 0, :air_filter_count.gt => 0, :cabin_filter_count.gt => 0).asc(:name)
        else
          render json: @auto_model.auto_submodels.where(data_source: 2, service_level: 1).where(:oil_filter_count.gt => 0, :air_filter_count.gt => 0, :cabin_filter_count.gt => 0).asc(:name).select {|sm| sm.parts.where(part_type_id: '522b2ed6098e713672000004', part_brand_id: '539d4d019a94e4de84000567').count > 0}
        end
      }
    end
  end

  # GET /auto_models/new
  # GET /auto_models/new.json
  def new
    @auto_model = AutoModel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @auto_model }
    end
  end

  # GET /auto_models/1/edit
  def edit
    @auto_model = AutoModel.find(params[:id])
  end

  # POST /auto_models
  # POST /auto_models.json
  def create
    @auto_model = AutoModel.new(params[:auto_model])

    respond_to do |format|
      if @auto_model.save
        format.html { redirect_to @auto_model, notice: 'Auto model was successfully created.' }
        format.json { render json: @auto_model, status: :created, location: @auto_model }
      else
        format.html { render action: "new" }
        format.json { render json: @auto_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /auto_models/1
  # PUT /auto_models/1.json
  def update
    @auto_model = AutoModel.find(params[:id])

    respond_to do |format|
      if @auto_model.update_attributes(params[:auto_model])
        format.html { redirect_to @auto_model, notice: 'Auto model was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @auto_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auto_models/1
  # DELETE /auto_models/1.json
  def destroy
    @auto_model = AutoModel.find(params[:id])
    @auto_model.destroy

    respond_to do |format|
      format.html { redirect_to auto_models_url }
      format.json { head :no_content }
    end
  end
end
