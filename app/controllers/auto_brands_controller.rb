# encoding : utf-8
class AutoBrandsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :set_default_operator
  # API test for Jason
  load_and_authorize_resource :except => [:index, :show]
  
  # GET /auto_brands
  # GET /auto_brands.json
  def index
    respond_to do |format|
      format.html {
        @auto_brands = AutoBrand.where(data_source: 2).asc(:name_pinyin).page params[:page]
      }
      format.json {
        @auto_brands = AutoBrand.where(data_source: 2, service_level: 1).asc(:name_pinyin)
        render json: @auto_brands
      }
    end
  end

  # GET /auto_brands/1
  # GET /auto_brands/1.json
  def show
    @auto_brand = AutoBrand.find(params[:id])
    if @auto_brand.auto_models.exists?
      @auto_submodels = @auto_brand.auto_models.first.auto_submodels.asc(:name).page params[:page]
    else
      @auto_submodels = []
    end
    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json {
        render json: @auto_brand.auto_models.where(service_level: 1).asc(:name_pinyin)
      }
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
