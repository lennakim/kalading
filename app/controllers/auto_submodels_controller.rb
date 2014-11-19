class AutoSubmodelsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_default_operator
  load_and_authorize_resource
  
  # GET /auto_submodels
  # GET /auto_submodels.json
  def index
    if params[:data_source]
      @ds = params[:data_source].to_i
    else
      @ds = 2
    end

    if params[:query] && params[:query] != ''
      @auto_submodels = AutoSubmodel.where(data_source: @ds).where(full_name: /.*#{params[:query].split('').join("\.\*")}.*/i)
      if @auto_submodels.empty?
        s = PinYin.of_string(params[:query]).join.gsub(/\s+/, "").split('').join("\.\*").gsub(/zhang/, 'chang')
        @auto_submodels = AutoSubmodel.where(data_source: @ds).where(full_name_pinyin: /.*#{s}.*/i).page params[:page]
      end
    elsif params[:model]
      @auto_submodels = AutoModel.find(params[:model]).auto_submodels.asc(:name).page params[:page]
    elsif params[:sanlv_ready]
      @auto_submodels = AutoSubmodel.where(data_source: @ds, service_level: 1).where(:oil_filter_count.gt => 0, :air_filter_count.gt => 0, :cabin_filter_count.gt => 0).page params[:page]
    elsif params[:oilf_soldout]
      @auto_submodels = AutoSubmodel.where(data_source: @ds).where(:oil_filter_count => 0, :air_filter_count.gt => 0, :cabin_filter_count.gt => 0).page params[:page]
    elsif params[:airf_soldout]
      @auto_submodels = AutoSubmodel.where(data_source: @ds).where(:oil_filter_count.gt => 0, :air_filter_count => 0, :cabin_filter_count.gt => 0).page params[:page]
    elsif params[:cabinf_soldout]
      @auto_submodels = AutoSubmodel.where(data_source: @ds).where(:oil_filter_count.gt => 0, :air_filter_count.gt => 0, :cabin_filter_count => 0).page params[:page]
    elsif params[:part_rule_exists]
      @auto_submodels = AutoSubmodel.where(data_source: @ds).not_in(part_rules: [nil, []]).page params[:page]
    elsif params[:motoroil_not_set]
      @auto_submodels = AutoSubmodel.where(data_source: @ds, motoroil_group: nil).page params[:page]
    else
      @auto_submodels = AutoSubmodel.where(data_source: @ds).desc(:updated_at).page params[:page]
      if params[:motoroil_cap]
        @auto_submodels = @auto_submodels.where motoroil_cap: params[:motoroil_cap].to_f
      end
    end

    respond_to do |format|
      format.html
      format.js
      format.json {
        if params[:query] && params[:query] != ''
          @auto_submodels = AutoSubmodel.where(data_source: @ds).where(full_name: /.*#{params[:query].split('').join("\.\*")}.*/i)
          if @auto_submodels.empty?
            s = PinYin.of_string(params[:query]).join.gsub(/\s+/, "").split('').join("\.\*").gsub(/zhang/, 'chang')
            @auto_submodels = AutoSubmodel.where(data_source: @ds).where(full_name_pinyin: /.*#{s}.*/i).limit(16)
          end
        elsif params[:auto_model_id] && params[:auto_model_id] != ''
          @auto_submodels = AutoModel.find(params[:auto_model_id]).auto_submodels.asc(:name)
        else 
          @auto_submodels = AutoSubmodel.where(data_source: @ds).limit(16)
        end
        render json: @auto_submodels
      }
    end
  end

  # GET /auto_submodels/1
  # GET /auto_submodels/1.json
  def show
    @auto_submodel = AutoSubmodel.find(params[:id])
    @auto_submodels = Kaminari.paginate_array([@auto_submodel]).page(0)
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
    @ds = @auto_submodel.data_source
  end

  # POST /auto_submodels
  # POST /auto_submodels.json
  def create
    @auto_submodel = AutoSubmodel.new(params[:auto_submodel])
    @auto_submodel.data_source = 3
    @auto_submodel.full_name = @auto_submodel.auto_model.full_name + ' ' + @auto_submodel.name + ' ' + @auto_submodel.engine_displacement + ' ' + @auto_submodel.year_range
    @auto_submodel.full_name_pinyin = PinYin.of_string(@auto_submodel.full_name.gsub(/\s+/, "")).join.gsub(/zhang/, 'chang')
    if params[:matched_auto_submodel]
      asm = AutoSubmodel.find params[:matched_auto_submodel]
      if asm
        asm.parts.each { |p| @auto_submodel.part << p }
        asm.part_rules.each { |p| @auto_submodel.part_rules << p }
      end
    end
    respond_to do |format|
      if @auto_submodel.save
        format.html { redirect_to auto_submodels_url, notice: 'Auto submodel was successfully created.' }
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
    if params[:auto_submodel][:data_source]
      # verify ok 
      @ds = params[:auto_submodel][:data_source].to_i
      # show visible asms after hiding a asm
      if @ds == 4
        @ds = 2
      end
    else
      @ds = @auto_submodel.data_source
      # need verification
      params[:auto_submodel][:data_source] = 3
    end
    respond_to do |format|
      if @auto_submodel.update_attributes(params[:auto_submodel])
        @notify_message = t(:auto_submodel_updated, n: @auto_submodel.full_name)
        format.html { redirect_to auto_submodels_url(data_source: @ds), notice: t('auto_submodel_updated') }
        format.js { render action: 'show'  }
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
  
  def oil_cap_edit
  end
  
  def oil_cap_modify
    params[:engine_displacement]
    params[:motoroil_cap]
    b = AutoBrand.find(params[:auto_model][:brand_id])
    c = 0
    if b
      b.auto_models.each do |m|
        m.auto_submodels.each do |sm|
          if sm.engine_displacement == params[:engine_displacement]
            sm.update_attributes(motoroil_cap: params[:motoroil_cap].to_f)
            c += 1
          end
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to auto_submodels_url, notice: t(:oil_cap_modified, n: b.name, d: params[:engine_displacement], c: c, oc: params[:motoroil_cap] ) }
      format.json { render json: {}, status: :created }
    end

  end
  
  def service_level_edit
  end
  
  def service_level_modify
    m = AutoModel.find(params[:auto_submodel][:model_id])
    return if !m
    if m
      m.auto_submodels.each do |sm|
        sm.update_attributes({service_level: params[:auto_model][:service_level].to_i})
      end
    end
    respond_to do |format|
      format.html { redirect_to auto_submodels_url, notice: t(:service_type_modified, n: m.full_name, c: m.auto_submodels.count, d: t(AutoSubmodel::SERV_LEVEL_STRINGS[params[:auto_model][:service_level].to_i]) ) }
      format.json { render json: {}, status: :created }
    end
  end
  
  def available_parts
    @auto_submodel = AutoSubmodel.find(params[:id])
    if params[:type].present?
      @parts = @auto_submodel.parts_includes_motoroil.select {|part| part.part_type.name == params[:type]}
    else
      @parts = @auto_submodel.parts
    end
  end

end
