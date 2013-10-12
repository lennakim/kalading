class AutoBrandsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_default_operator
  
  # GET /auto_brands
  # GET /auto_brands.json
  def index
    @auto_brands = AutoBrand.all.page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @auto_brands }
    end
  end

  # GET /auto_brands/1
  # GET /auto_brands/1.json
  def show
    @auto_brand = AutoBrand.find(params[:id])
    @auto_submodels = @auto_brand.auto_models.first.auto_submodels.page params[:page]

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @auto_brand }
    end
  end

  # GET /auto_brands/new
  # GET /auto_brands/new.json
  def new
    @auto_brand = AutoBrand.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @auto_brand }
    end
  end

  # GET /auto_brands/1/edit
  def edit
    @auto_brand = AutoBrand.find(params[:id])
  end

  # POST /auto_brands
  # POST /auto_brands.json
  def create
    @auto_brand = AutoBrand.new(params[:auto_brand])

    respond_to do |format|
      if @auto_brand.save
        format.html { redirect_to @auto_brand, notice: 'Auto brand was successfully created.' }
        format.json { render json: @auto_brand, status: :created, location: @auto_brand }
      else
        format.html { render action: "new" }
        format.json { render json: @auto_brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /auto_brands/1
  # PUT /auto_brands/1.json
  def update
    @auto_brand = AutoBrand.find(params[:id])

    respond_to do |format|
      if @auto_brand.update_attributes(params[:auto_brand])
        format.html { redirect_to @auto_brand, notice: 'Auto brand was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @auto_brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auto_brands/1
  # DELETE /auto_brands/1.json
  def destroy
    @auto_brand = AutoBrand.find(params[:id])
    @auto_brand.destroy

    respond_to do |format|
      format.html { redirect_to auto_brands_url }
      format.json { head :no_content }
    end
  end
end
