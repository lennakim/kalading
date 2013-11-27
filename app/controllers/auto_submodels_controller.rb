class AutoSubmodelsController < ApplicationController
  before_filter :authenticate_user! if !Rails.env.importdata?
  before_filter :set_default_operator
  load_and_authorize_resource :except => [:import]
  
  # GET /auto_submodels
  # GET /auto_submodels.json
  def index
    #asms1 = AutoSubmodel.any_of({year_range: /.*\s.*/})
    #asms1.each do |asm1|
    #  asms2 = AutoSubmodel.all_of :year_range.not => /.*\s.*/,
    #    :name => asm1.name,
    #    :auto_model_id => asm1.auto_model.id,
    #    :engine_model => /.*#{asm1.engine_model}*/
    #  if asms2.exists?
    #    asm2 = asms2.first
    #    asm1.update_attributes order_ids: asm2.order_ids | asm1.order_ids,
    #      part_ids: asm2.part_ids | asm1.part_ids,
    #      auto_ids: asm2.auto_ids | asm1.auto_ids
    #    asm2.destroy
    #  end
    #end

    respond_to do |format|
      format.html {
        @auto_submodels = AutoSubmodel.asc(:created_at).page params[:page]
      }
      format.js {
        if params[:search]
          @auto_submodels = AutoSubmodel.search(:name, params[:search]).asc(:name).page params[:page]
        elsif params[:model] && params[:year]
          if params[:year] == I18n.t(:all)
            @auto_submodels = AutoModel.find(params[:model]).auto_submodels.asc(:name).page params[:page]
          else
            @auto_submodels = AutoModel.find(params[:model]).auto_submodels.any_of({ :name => /.*#{params[:year]}.*/i }).asc(:name).page params[:page]
          end
        else
          @auto_submodels = AutoSubmodel.all.page params[:page]
        end
      }
      format.json {
        begin
          @auto_submodels = AutoBrand.find_by(name: params[:brand]).auto_models.find_by(name: params[:model]).auto_submodels.where(name: params[:submodel])
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
        if params[:auto_model_name] && params[:auto_model_name] != '' && params[:auto_model_name] != @auto_submodel.auto_model.name
          @auto_submodel.auto_model.update_attributes({name: params[:auto_model_name]})
        end
        
        hengst_brand = PartBrand.find_or_create_by name: I18n.t(:hengst)
        if params[:hengst_oil_filter]
          oil_filter_type = PartType.find_or_create_by name: I18n.t(:oil_filter)
          @auto_submodel.parts.where(part_brand_id: hengst_brand.id, part_type_id: oil_filter_type.id).delete_all
          params[:hengst_oil_filter].split(';').each do |number|
            part = Part.find_or_create_by(number: number, part_brand_id: hengst_brand.id, part_type_id: oil_filter_type.id)
            @auto_submodel.parts << part
          end
        end
        if params[:hengst_fuel_filter]
          fuel_filter_type = PartType.find_or_create_by name: I18n.t(:fuel_filter)
          @auto_submodel.parts.where(part_brand_id: hengst_brand.id, part_type_id: fuel_filter_type.id).delete_all
          params[:hengst_fuel_filter].split(';').each do |number|
            part = Part.find_or_create_by(number: number, part_brand_id: hengst_brand.id, part_type_id: fuel_filter_type.id)
            @auto_submodel.parts << part
          end
        end
        if params[:hengst_air_filter]
          air_filter_type = PartType.find_or_create_by name: I18n.t(:air_filter)
          @auto_submodel.parts.where(part_brand_id: hengst_brand.id, part_type_id: air_filter_type.id).delete_all
          params[:hengst_air_filter].split(';').each do |number|
            part = Part.find_or_create_by(number: number, part_brand_id: hengst_brand.id, part_type_id: air_filter_type.id)
            @auto_submodel.parts << part
          end
        end
        if params[:hengst_cabin_filter]
          cabin_filter_type = PartType.find_or_create_by name: I18n.t(:cabin_filter)
          @auto_submodel.parts.where(part_brand_id: hengst_brand.id, part_type_id: cabin_filter_type.id).delete_all
          params[:hengst_cabin_filter].split(';').each do |number|
            part = Part.find_or_create_by(number: number, part_brand_id: hengst_brand.id, part_type_id: cabin_filter_type.id)
            @auto_submodel.parts << part
          end
        end
        @notify_message = t(:auto_submodel_updated, n: @auto_submodel.full_name)
        format.html { redirect_to @auto_submodel, notice: 'Auto submodel was successfully updated.' }
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
  
  def edit_with_catalog
    @auto_submodel = AutoSubmodel.first
  end
  
  def import
    ab = AutoBrand.find_or_create_by name_mann: params[:brand_name]
    
    am = AutoModel.find_or_create_by name_mann: params[:model_name], auto_brand_id: ab.id
    full_name = am.auto_brand.name + ' ' + am.name
    full_name.gsub!(/\s+/, "")
    am.update_attributes({
                    full_name_pinyin: PinYin.of_string(full_name).join
                  })
    
    asm = AutoSubmodel.find_or_create_by :name => params[:submodel_name],
      :auto_model_id => am.id,
      :engine_model => params[:engine_model]

    #asm.update_attributes match_rule: params[:limit]

    if params[:parts]
      params[:parts].each do |part_data|
        pb = PartBrand.find_or_create_by name: part_data[:part_brand_name]
        pt = PartType.find_or_create_by name: part_data[:part_type_name]
        p = Part.find_or_create_by number: part_data[:number], part_brand_id: pb.id, part_type_id: pt.id
        p.auto_submodels << asm
        asm.parts << p
      end
    end
    respond_to do |format|
      format.html { redirect_to auto_submodels_url }
      format.json { head :no_content }
    end
  end
end
