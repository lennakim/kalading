class AutoSubmodelsController < ApplicationController
  #before_filter :authenticate_user!
  before_filter :set_default_operator
  
  # GET /auto_submodels
  # GET /auto_submodels.json
  def index
    respond_to do |format|
      format.html {
        @auto_submodels = AutoSubmodel.all.page params[:page]
      }
      format.js{
        if params[:search]
          @auto_submodels = AutoSubmodel.search(:name, params[:search]).asc(:name).page params[:page]
        elsif params[:model] && params[:year]
          if params[:year] == I18n.t(:all)
            @auto_submodels = AutoModel.find(params[:model]).auto_submodels.asc(:name).page params[:page]
          else
            @auto_submodels = AutoModel.find(params[:model]).auto_submodels.any_of({ :name => /.*#{params[:year]}.*/i }).asc(:name).page params[:page]
          end
        end
      }
      format.json {
        begin
          @auto_submodels = AutoBrand.where(name: params[:brand]).first.auto_models.where(name: params[:model]).first.auto_submodels.where(name: params[:submodel])
          render json: @auto_submodels
        rescue
          render json: []
        end
      }
    end
  end

  # GET /auto_submodels/1
  # GET /auto_submodels/1.json
  def show
    @auto_submodel = AutoSubmodel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @auto_submodel }
    end
  end

  # GET /auto_submodels/new
  # GET /auto_submodels/new.json
  def new
    @auto_submodel = AutoSubmodel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @auto_submodel }
    end
  end

  # GET /auto_submodels/1/edit
  def edit
    @auto_submodel = AutoSubmodel.find(params[:id])
  end

  # POST /auto_submodels
  # POST /auto_submodels.json
  def create
    @auto_submodel = AutoSubmodel.new(params[:auto_submodel])

    respond_to do |format|
      if @auto_submodel.save
        format.html { redirect_to @auto_submodel, notice: 'Auto submodel was successfully created.' }
        format.json { render json: @auto_submodel, status: :created, location: @auto_submodel }
      else
        format.html { render action: "new" }
        format.json { render json: @auto_submodel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /auto_submodels/1
  # PUT /auto_submodels/1.json
  def update
    @auto_submodel = AutoSubmodel.find(params[:id])

    respond_to do |format|
      if @auto_submodel.update_attributes(params[:auto_submodel])
        format.html { redirect_to @auto_submodel, notice: 'Auto submodel was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @auto_submodel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auto_submodels/1
  # DELETE /auto_submodels/1.json
  def destroy
    @auto_submodel = AutoSubmodel.find(params[:id])
    @auto_submodel.destroy

    respond_to do |format|
      format.html { redirect_to auto_submodels_url }
      format.json { head :no_content }
    end
  end
end
