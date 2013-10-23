class PartBrandsController < ApplicationController
  #before_filter :authenticate_user!
  before_filter :set_default_operator
  
  # GET /part_brands
  # GET /part_brands.json
  def index
    @part_brands = PartBrand.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @part_brands }
    end
  end

  # GET /part_brands/1
  # GET /part_brands/1.json
  def show
    @part_brand = PartBrand.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @part_brand }
    end
  end

  # GET /part_brands/new
  # GET /part_brands/new.json
  def new
    @part_brand = PartBrand.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @part_brand }
    end
  end

  # GET /part_brands/1/edit
  def edit
    @part_brand = PartBrand.find(params[:id])
  end

  # POST /part_brands
  # POST /part_brands.json
  def create
    @part_brand = PartBrand.new(params[:part_brand])

    respond_to do |format|
      if @part_brand.save
        format.html { redirect_to @part_brands_url, notice: 'Part brand was successfully created.' }
        format.json { render json: @part_brand, status: :created, location: @part_brand }
      else
        format.html { render action: "new" }
        format.json { render json: @part_brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /part_brands/1
  # PUT /part_brands/1.json
  def update
    @part_brand = PartBrand.find(params[:id])

    respond_to do |format|
      if @part_brand.update_attributes(params[:part_brand])
        format.html { redirect_to @part_brand, notice: 'Part brand was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @part_brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /part_brands/1
  # DELETE /part_brands/1.json
  def destroy
    @part_brand = PartBrand.find(params[:id])
    @part_brand.destroy

    respond_to do |format|
      format.html { redirect_to part_brands_url }
      format.json { head :no_content }
    end
  end
end
