class MotoroilGroupsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /motoroil_groups
  # GET /motoroil_groups.json
  def index
    @motoroil_groups = MotoroilGroup.asc(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @motoroil_groups }
    end
  end

  # GET /motoroil_groups/1
  # GET /motoroil_groups/1.json
  def show
    @motoroil_group = MotoroilGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @motoroil_group }
    end
  end

  # GET /motoroil_groups/new
  # GET /motoroil_groups/new.json
  def new
    @motoroil_group = MotoroilGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @motoroil_group }
    end
  end

  # GET /motoroil_groups/1/edit
  def edit
    @motoroil_group = MotoroilGroup.find(params[:id])
  end

  # POST /motoroil_groups
  # POST /motoroil_groups.json
  def create
    @motoroil_group = MotoroilGroup.new(params[:motoroil_group])
    @motoroil_group.parts_order = Hash[params[:motoroil_group][:part_ids].zip (0..params[:motoroil_group][:part_ids].size)]

    respond_to do |format|
      if @motoroil_group.save
        format.html { redirect_to motoroil_groups_url, notice: 'Motoroil class was successfully created.' }
        format.json { render json: @motoroil_group, status: :created, location: @motoroil_group }
      else
        format.html { render action: "new" }
        format.json { render json: @motoroil_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /motoroil_groups/1
  # PUT /motoroil_groups/1.json
  def update
    @motoroil_group = MotoroilGroup.find(params[:id])
    params[:motoroil_group][:parts_order] = Hash[params[:motoroil_group][:part_ids].zip (0..params[:motoroil_group][:part_ids].size)]
    respond_to do |format|
      if @motoroil_group.update_attributes(params[:motoroil_group])
        format.html { redirect_to motoroil_groups_url, notice: 'Motoroil class was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @motoroil_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /motoroil_groups/1
  # DELETE /motoroil_groups/1.json
  def destroy
    @motoroil_group = MotoroilGroup.find(params[:id])
    @motoroil_group.destroy

    respond_to do |format|
      format.html { redirect_to motoroil_groups_url }
      format.json { head :no_content }
    end
  end
end
