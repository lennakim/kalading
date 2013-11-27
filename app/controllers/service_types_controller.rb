class ServiceTypesController < ApplicationController
  before_filter :authenticate_user! if !Rails.env.importdata?
  before_filter :set_default_operator
  load_and_authorize_resource
  
  # GET /service_types
  # GET /service_types.json
  def index
    @service_types = ServiceType.asc(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @service_types }
    end
  end

  # GET /service_types/1
  # GET /service_types/1.json
  def show
    @service_type = ServiceType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @service_type }
    end
  end

  # GET /service_types/new
  # GET /service_types/new.json
  def new
    @service_type = ServiceType.new
    @service_type.price = Money.new(1.0)
    @service_type.auto_model = AutoBrand.first.auto_models.first
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @service_type }
    end
  end

  # GET /service_types/1/edit
  def edit
    @service_type = ServiceType.find(params[:id])
    @service_type.auto_model = AutoBrand.first.auto_models.first if !@service_type.auto_model
  end

  # POST /service_types
  # POST /service_types.json
  def create
    @service_type = ServiceType.new(params[:service_type])

    respond_to do |format|
      if @service_type.save
        format.html { redirect_to service_types_url, notice: 'Service type was successfully created.' }
        format.json { render json: @service_type, status: :created, location: @service_type }
      else
        format.html { render action: "new" }
        format.json { render json: @service_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /service_types/1
  # PUT /service_types/1.json
  def update
    @service_type = ServiceType.find(params[:id])
    if params[:service_type][:auto_model_id] == I18n.t(:all_models)
      params[:service_type][:auto_model_id] = nil
    end
    
    respond_to do |format|
      if @service_type.update_attributes(params[:service_type])
        format.html { redirect_to service_types_url, notice: 'Service type was successfully updated.' }
        format.json { render json: @service_type, status: :created, location: @service_type }
      else
        format.html { render action: "edit" }
        format.json { render json: @service_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /service_types/1
  # DELETE /service_types/1.json
  def destroy
    @service_type = ServiceType.find(params[:id])
    @service_type.destroy

    respond_to do |format|
      format.html { redirect_to service_types_url }
      format.json { head :no_content }
    end
  end
end
