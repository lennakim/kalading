# encoding : utf-8
class AutoBrandsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show] if !Rails.env.importdata?
  before_filter :set_default_operator
  # API test for Jason
  load_and_authorize_resource :except => [:index, :show]
  
  # GET /auto_brands
  # GET /auto_brands.json
  def index
    #if AutoBrand.first.name_pinyin.nil?
      #AutoBrand.each do |ab|
      #  ab.update_attributes({ name_pinyin: PinYin.of_string(ab.name).join} ) if ab.name_pinyin.nil?
      #end
      #AutoBrand.find_by(name: '长城汽车(中国) / GREATWALL').update_attributes({name_pinyin: 'changchengqichezhongguoGREATWALL'})
      #AutoBrand.find_by(name: '长安汽车(中国) / CHANGAN').update_attributes({name_pinyin: 'changanqichezhongguoCHANGAN'})
    #end
    
    #AutoBrand.each do |m|
    #  m.update_attributes name_mann: m.name
    #end

    #AutoBrand.each do |m|
    #  m.update_attributes name: (m.name.gsub /(\/.*\()/, '(')
    #end


    #AutoBrand.each do |m|
    #  m.update_attributes name: (m.name.gsub /(\/.*)/, '')
    #end

    #AutoBrand.each do |m|
    #  m.update_attributes name: (m.name.gsub /(\(中国\))/, '')
    #end

    #AutoBrand.each do |m|
    #  m.update_attributes name: (m.name.strip)
    #end

    #AutoBrand.each do |m|
    #  m.update_attributes name: (m.name.gsub /(\([A-Z,\.]+\))/, '')
    #end

    @auto_brands = AutoBrand.all.page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: AutoBrand.all }
    end
  end

  # GET /auto_brands/1
  # GET /auto_brands/1.json
  def show
    @auto_brand = AutoBrand.find(params[:id])
    @auto_submodels = @auto_brand.auto_models.first.auto_submodels.asc(:name).page params[:page]
    @auto_submodel = @auto_submodels.first
    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @auto_brand.auto_models }
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
