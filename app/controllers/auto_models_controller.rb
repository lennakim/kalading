class AutoModelsController < ApplicationController
  before_filter :authenticate_user! if !Rails.env.importdata?
  before_filter :set_default_operator
  load_and_authorize_resource
  
  def convert_to_pinyin
    AutoModel.all.each do |m|
      full_name = m.auto_brand.name + ' ' + m.name
      full_name.gsub!(/\s+/, "")
      m.update_attributes({
                      full_name_pinyin: PinYin.of_string(full_name).join
                    })
    end
  end
  
  # GET /auto_models
  # GET /auto_models.json
  def index
    if params[:query] && params[:query] != ''
      params[:query] = PinYin.of_string(params[:query]).join
      params[:query].gsub!(/\s+/, "")
      s = params[:query].split('').join(".*")
      @auto_models = AutoModel.any_of({ full_name_pinyin: /.*#{s}.*/i })
    else
      @auto_models = AutoModel.all.page params[:page]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @auto_models }
    end
  end

  # GET /auto_models/1
  # GET /auto_models/1.json
  def show
    @auto_model = AutoModel.find(params[:id])
    @auto_submodels = @auto_model.auto_submodels.asc(:name).page params[:page]
    @auto_submodel = @auto_submodels.first
    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @auto_model }
    end
  end

  # GET /auto_models/new
  # GET /auto_models/new.json
  def new
    @auto_model = AutoModel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @auto_model }
    end
  end

  # GET /auto_models/1/edit
  def edit
    @auto_model = AutoModel.find(params[:id])
  end

  # POST /auto_models
  # POST /auto_models.json
  def create
    @auto_model = AutoModel.new(params[:auto_model])

    respond_to do |format|
      if @auto_model.save
        format.html { redirect_to @auto_model, notice: 'Auto model was successfully created.' }
        format.json { render json: @auto_model, status: :created, location: @auto_model }
      else
        format.html { render action: "new" }
        format.json { render json: @auto_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /auto_models/1
  # PUT /auto_models/1.json
  def update
    @auto_model = AutoModel.find(params[:id])

    respond_to do |format|
      if @auto_model.update_attributes(params[:auto_model])
        format.html { redirect_to @auto_model, notice: 'Auto model was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @auto_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auto_models/1
  # DELETE /auto_models/1.json
  def destroy
    @auto_model = AutoModel.find(params[:id])
    @auto_model.destroy

    respond_to do |format|
      format.html { redirect_to auto_models_url }
      format.json { head :no_content }
    end
  end
end
