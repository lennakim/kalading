class PicturesController < ApplicationController
  before_filter :check_for_mobile, :only => [:new, :edit, :index, :show]
  before_filter :authenticate_user!
  before_filter :set_default_operator
  
  
  # GET /pictures
  # GET /pictures.json
  def index
    @pictures = Picture.all.page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pictures }
    end
  end

  # GET /pictures/1
  # GET /pictures/1.json
  def show
    @picture = Picture.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @picture }
    end
  end

  # GET /pictures/new
  # GET /pictures/new.json
  def new
    @picture = Picture.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @picture }
    end
  end

  # GET /pictures/1/edit
  def edit
    @picture = Picture.find(params[:id])
  end

  # POST /pictures
  # POST /pictures.json
  def create
    @picture = Picture.new(params[:order])

    respond_to do |format|
      if @picture.save
        format.html { redirect_to pictures_url, notice: 'Order was successfully created.' }
        format.json { render json: @picture, status: :created, location: @picture }
      else
        format.html { render action: "new" }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pictures/1
  # PUT /pictures/1.json
  def update
    @picture = Picture.find(params[:id])

    respond_to do |format|
      if @picture.update_attributes(params[:order])
        format.html { redirect_to pictures_url, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pictures/1
  # DELETE /pictures/1.json
  def destroy
    if params[:order_id]
      o = Order.find(params[:order_id])
      @picture = o.pictures.find(params[:id])
      @picture.destroy
    elsif params[:auto_submodel_id]
      a = AutoSubmodel.find(params[:auto_submodel_id])
      @picture = a.pictures.find(params[:id])
      @picture.destroy
    end

    respond_to do |format|
      format.html { redirect_to o }
      format.json { head :no_content }
    end
  end
 
end
