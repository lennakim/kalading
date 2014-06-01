class PartsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_default_operator
  load_and_authorize_resource
  
  # GET /parts
  # GET /parts.json
  def index
    if params[:search] && params[:search] != ''
      s = params[:search].gsub(/\s+/, "").split('').join(".*")
      @parts = Part.where(:number => /.*#{s}.*/i).asc(:number)
    else
      @parts = Part.asc(:number)
    end
    
    if params[:part_search]
      if params[:part_search][:type_id] != ''
        @parts = @parts.where(part_type: PartType.find(params[:part_search][:type_id])).asc(:number)
      end
      if params[:part_search][:brand_id] != ''
        @parts = @parts.where(part_brand: PartBrand.find(params[:part_search][:brand_id])).asc(:number)
      end
    end
    @parts = @parts.any_in( _id: Urlinfo.all.distinct("part_id") ) if params[:has_urlinfo]
    @parts = @parts.not_in( _id: Urlinfo.all.distinct("part_id") ) if params[:no_urlinfo]
    
    respond_to do |format|
      format.html {@parts = @parts.page params[:page]}
      format.js   {@parts = @parts.page params[:page]}
      format.json { render json: @parts }
    end
  end

  # GET /parts/1
  # GET /parts/1.json
  def show
    @part = Part.find(params[:id])
    @auto_submodels = @part.auto_submodels.where(data_source: 2).page(params[:page])

    respond_to do |format|
      format.html
      format.js
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
    matches = Part.where number: /.*#{@part.number.gsub(/\s+/, "").split('').join(".*")}.*/i, part_brand_id: @part.part_brand, part_type_id: @part.part_type
    if matches.exists?
      len_matched = matches.select {|x| x.number.gsub(/\s+/, "").size == @part.number.gsub(/\s+/, "").size }
      if !len_matched.empty?
        render json: {status: :bad_request}
      end
    end

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
        format.html { redirect_to parts_url, notice: 'Part was successfully updated.' }
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
      format.js
      format.json { head :no_content }
    end
  end
  
  def edit_part_automodel
    @part = Part.find(params[:id])
    #@auto_submodels = Kaminari.paginate_array(@part.auto_submodels).page(0).per(5)
    @auto_submodels = @part.auto_submodels.any_of({ data_source: 2 }, { data_source: 3 }, { data_source: 4 })
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
    @auto_submodel.parts << @part
    @part.auto_submodels << @auto_submodel
    @auto_submodels = @part.auto_submodels
  end
  
  def match
    pb = PartBrand.find_by name: I18n.t(:mann)
    @parts = Part.where(part_brand_id: pb.id)
    if params[:search] && params[:search] != ''
      s = params[:search].split('').join(".*")
      @parts = @parts.where :number => /.*#{s}.*/i
    end
    @total_parts = @parts.asc(:part_type_id).select {|x| x.total_remained_quantity > 0}
    @parts = Kaminari.paginate_array(@total_parts).page params[:page]
  end
  
  def part_select
    @part = Part.find(params[:id])
    @part_brands = PartBrand.all.excludes(id: @part.part_brand.id)
    #.select {|pb| pb.parts.where(part_type_id: @part.part_type.id).exists? }
    @parts = @part_brands.first.parts.where(part_type_id: @part.part_type.id)
  end
  
  def update_part_select
    @part = Part.find(params[:id])
    pb = PartBrand.find params[:part_match][:brand_id]
    if params[:part_match][:new_number] != ''
      s = params[:part_match][:new_number].gsub(/\s+/, "").split('').join(".*")
      matches = Part.where number: /.*#{s}.*/i, part_brand_id: pb.id, part_type_id: @part.part_type.id
      len_matched = matches.select {|x| x.number.gsub(/\s+/, "").size == number.gsub(/\s+/, "").size }
      if len_matched.exists?
        @matched_part = len_matched[0]
      else
        @matched_part = Part.create number: params[:part_match][:new_number], part_brand_id: pb.id, part_type_id: @part.part_type.id
      end
    else
      @matched_part = Part.find(params[:part_match][:id])
    end
    @part.auto_submodels.where(data_source: 2).each do |asm|
      asm.parts << @matched_part
      if asm.part_rules.exists?
        pr = asm.part_rules.find_by number: @part.number
        if pr
          asm.part_rules.create(number: @matched_part.number, text: pr.text)
        end
      end
      asm.update_attributes data_source: 3
    end
  end
  
  def parts_by_brand_and_type
    pb = PartBrand.find params[:brand_id]
    pt = PartType.find params[:type_id]
    @parts = pb.parts.where(part_type_id: pt.id)
  end
  
  def delete_match
    @part = Part.find(params[:id])
    @matched_part = Part.find(params[:match_id])
    @part.auto_submodels.where(data_source: 2).each do |asm|
      asm.parts.delete @matched_part
      asm.part_rules.destroy_all(number: @matched_part.number)
    end
  end
  
  def destroy_urlinfo
    @part = Part.find(params[:id])
    ui = Urlinfo.find(params[:url])
    @part.urlinfos.delete ui
    ui.destroy
  end
end
