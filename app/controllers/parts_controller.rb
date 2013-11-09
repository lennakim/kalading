class PartsController < ApplicationController
  before_filter :authenticate_user! if !Rails.env.importdata?
  before_filter :set_default_operator
  
  # GET /parts
  # GET /parts.json
  def index
    if params[:search] != ''
      @parts = Part.search(:number, params[:search])
    else
      @parts = Part.all
    end
    
    if params[:part_search]
      if params[:part_search][:type_id] != ''
        @parts = @parts.where(part_type: PartType.find(params[:part_search][:type_id]))
      end
      if params[:part_search][:brand_id] != ''
        @parts = @parts.where(part_brand: PartBrand.find(params[:part_search][:brand_id]))
      end
    end
    @parts = @parts.page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.js # index.html.erb
      format.json { render json: @parts }
    end
  end

  # GET /parts/1
  # GET /parts/1.json
  def show
    @part = Part.find(params[:id])
    @auto_submodels = @part.auto_submodels.page(params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @part }
    end
  end

  # GET /parts/new
  # GET /parts/new.json
  def new
    @part = Part.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @part }
    end
  end

  # GET /parts/1/edit
  def edit
    @part = Part.find(params[:id])
  end

  # POST /parts
  # POST /parts.json
  def create
    @part = Part.new(params[:part])

    respond_to do |format|
      if @part.save
        format.html { redirect_to parts_url, notice: 'Part was successfully created.' }
        format.json { render json: @part, status: :created, location: @part }
      else
        format.html { render action: "new" }
        format.json { render json: @part.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /parts/1
  # PUT /parts/1.json
  def update
    @part = Part.find(params[:id])

    respond_to do |format|
      if @part.update_attributes(params[:part])
        format.html { redirect_to @part, notice: 'Part was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @part.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parts/1
  # DELETE /parts/1.json
  def destroy
    @part = Part.find(params[:id])
    @part.destroy

    respond_to do |format|
      format.html { redirect_to parts_url }
      format.json { head :no_content }
    end
  end
  
  def edit_part_automodel
    @part = Part.find(params[:id])
    #@auto_submodels = Kaminari.paginate_array(@part.auto_submodels).page(0).per(5)
    @auto_submodels = @part.auto_submodels
  end
  
  def delete_auto_submodel
    @part = Part.find(params[:id])
    @auto_submodel = AutoSubmodel.find(params[:auto_submodel_id])
    @part.auto_submodels.delete(@auto_submodel)
    @auto_submodel.parts.delete(@part)
  end
  
  def add_auto_submodel
    @part = Part.find(params[:id])
    if @auto_submodel = @part.auto_submodels.find(params[:auto][:auto_submodel_id])
      @error = I18n.t(:part_auto_submodel_exists,
                      name: @auto_submodel.full_name)
      return
    end

    @auto_submodel = AutoSubmodel.find(params[:auto][:auto_submodel_id])
    @part.auto_submodels << @auto_submodel
    @auto_submodel.parts << @part
    @auto_submodels = @part.auto_submodels
  end
end
