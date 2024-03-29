class PartbatchesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_default_operator
  load_and_authorize_resource
  
  # GET /partbatches
  # GET /partbatches.json
  def index
    @partbatches = Partbatch.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @partbatches }
    end
  end

  # GET /partbatches/1
  # GET /partbatches/1.json
  def show
    @partbatch = Partbatch.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @partbatch }
    end
  end

  # GET /partbatches/new
  # GET /partbatches/new.json
  def new
    @storehouse = Storehouse.find(params[:storehouse_id])
    @partbatch = @storehouse.partbatches.new
    @part = Part.first
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @partbatch }
    end
  end

  # GET /partbatches/1/edit
  def edit
    @partbatch = Partbatch.find(params[:id])
    @storehouse = @partbatch.storehouse
    @part = @partbatch.part
  end

  # POST /partbatches
  # POST /partbatches.json
  def create
    @storehouse = Storehouse.find(params[:storehouse_id])
    @partbatch = @storehouse.partbatches.new(params[:partbatch])
    @part = Part.find(params[:partbatch][:part_id])

    respond_to do |format|
      if @partbatch.save
        format.html { redirect_to @storehouse, notice: I18n.t(:partbatch_created) }
        format.json { render json: @partbatch, status: :created, location: @partbatch }
      else
        format.html { render action: "new" }
        format.json { render json: @partbatch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /partbatches/1
  # PUT /partbatches/1.json
  def update
    @partbatch = Partbatch.find(params[:id])
    @part = Part.find(params[:partbatch][:part_id])
    respond_to do |format|
      if @partbatch.update_attributes(params[:partbatch])
        format.html { redirect_to @partbatch, notice: 'Partbatch was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @partbatch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /partbatches/1
  # DELETE /partbatches/1.json
  def destroy
    @partbatch = Partbatch.find(params[:id])
    @partbatch.destroy

    respond_to do |format|
      format.html { redirect_to partbatches_url }
      format.json { head :no_content }
    end
  end

end
