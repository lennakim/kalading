class ServiceItemsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_default_operator
  
  # GET /service_items
  # GET /service_items.json
  def index
    @service_items = ServiceItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @service_items }
    end
  end

  # GET /service_items/1
  # GET /service_items/1.json
  def show
    @service_item = ServiceItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @service_item }
    end
  end

  # GET /service_items/new
  # GET /service_items/new.json
  def new
    @service_item = ServiceItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @service_item }
    end
  end

  # GET /service_items/1/edit
  def edit
    @service_item = ServiceItem.find(params[:id])
  end

  # POST /service_items
  # POST /service_items.json
  def create
    @service_item = ServiceItem.new(params[:service_item])

    respond_to do |format|
      if @service_item.save
        format.html { redirect_to @service_item, notice: 'Service item was successfully created.' }
        format.json { render json: @service_item, status: :created, location: @service_item }
      else
        format.html { render action: "new" }
        format.json { render json: @service_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /service_items/1
  # PUT /service_items/1.json
  def update
    @service_item = ServiceItem.find(params[:id])

    respond_to do |format|
      if @service_item.update_attributes(params[:service_item])
        format.html { redirect_to @service_item, notice: 'Service item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @service_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /service_items/1
  # DELETE /service_items/1.json
  def destroy
    @service_item = ServiceItem.find(params[:id])
    @service_item.destroy

    respond_to do |format|
      format.html { redirect_to service_items_url }
      format.json { head :no_content }
    end
  end
end
