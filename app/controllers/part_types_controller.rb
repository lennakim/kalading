class PartTypesController < ApplicationController
  before_filter :authenticate_user! if !Rails.env.importdata?
  before_filter :set_default_operator
  
  # GET /part_types
  # GET /part_types.json
  def index
    @parts = [[I18n.t(:all_part_numbers), '']]
    @part_types = PartType.all
    @parts.concat(Part.all.asc(:number).map {|p| [p.number, p.id]})
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @part_types }
    end
  end

  # GET /part_types/1
  # GET /part_types/1.json
  def show
    @parts = [[I18n.t(:all_part_numbers), '']]
    @part_type = PartType.find(params[:id])
    @parts.concat(@part_type.parts.asc(:number).map {|p| [p.number, p.id]})

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @part_type }
    end
  end

  # GET /part_types/new
  # GET /part_types/new.json
  def new
    @part_type = PartType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @part_type }
    end
  end

  # GET /part_types/1/edit
  def edit
    @part_type = PartType.find(params[:id])
  end

  # POST /part_types
  # POST /part_types.json
  def create
    @part_type = PartType.new(params[:part_type])

    respond_to do |format|
      if @part_type.save
        format.html { redirect_to @part_types_url, notice: 'Part type was successfully created.' }
        format.json { render json: @part_type, status: :created, location: @part_type }
      else
        format.html { render action: "new" }
        format.json { render json: @part_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /part_types/1
  # PUT /part_types/1.json
  def update
    @part_type = PartType.find(params[:id])

    respond_to do |format|
      if @part_type.update_attributes(params[:part_type])
        format.html { redirect_to @part_type, notice: 'Part type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @part_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /part_types/1
  # DELETE /part_types/1.json
  def destroy
    @part_type = PartType.find(params[:id])
    @part_type.destroy

    respond_to do |format|
      format.html { redirect_to part_types_url }
      format.json { head :no_content }
    end
  end
end
