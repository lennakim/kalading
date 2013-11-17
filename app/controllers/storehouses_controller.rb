class StorehousesController < ApplicationController
  before_filter :authenticate_user! if !Rails.env.importdata?
  before_filter :set_default_operator
  load_and_authorize_resource

  # GET /storehouses
  # GET /storehouses.json
  def index
    @storehouses = Storehouse.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @storehouses }
    end
  end

  # GET /storehouses/1
  # GET /storehouses/1.json
  def show
    @storehouse = Storehouse.find(params[:id])
    if params[:partbatch_id] # search by partbatch id
      pb = @storehouse.partbatches.find(params[:partbatch_id])
      pbs = []
      pbs << pb if pb
    else
      pbs = @storehouse.partbatches.desc(:created_at)
      if params[:partbatch_part] # search by part
        if params[:partbatch_part][:type_id] != ''
          part_type = PartType.find params[:partbatch_part][:type_id]
          pbs = pbs.select { |pb| pb.part.part_type == part_type } if part_type
        end
        if params[:partbatch_part][:brand_id] != ''
          part_brand = PartBrand.find params[:partbatch_part][:brand_id]
          pbs = pbs.select { |pb| pb.part.part_brand == part_brand } if part_brand
        end
        if params[:part_number] && params[:part_number] != ''
          parts = Part.where(number: params[:part_number])
          pbs = pbs.select { |pb| parts.include? pb.part }
        end
      end
  
      if params[:auto] # search by auto submodel
        if params[:auto][:auto_submodel_id] != ''
          pbs = pbs.select { |pb| pb.part.auto_submodels.find(params[:auto][:auto_submodel_id]) }
        end
      end
  
      if params[:order] # search by order seq
        o = Order.where(seq: params[:order])
        pbs = pbs.select { |pb| o.parts.find(pb.part) } if o
      end
    end

    @partbatches = Kaminari.paginate_array(pbs).page(params[:page]).per(5)
    @history_trackers = Kaminari.paginate_array(HistoryTracker.where(scope: 'partbatch').desc(:created_at)).page(0).per(5)

    respond_to do |format|
      format.html # show.html.erb
      format.js # show.js.erb
      format.json { render json: @partbatches }
    end
  end

  def show_history
    @storehouse = Storehouse.find(params[:id])
    @history_trackers = Kaminari.paginate_array(HistoryTracker.where(scope: 'partbatch').desc(:created_at)).page(params[:pagina]).per(5)
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @history_trackers }
    end
  end
  
  # GET /storehouses/new
  # GET /storehouses/new.json
  def new
    @storehouse = Storehouse.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @storehouse }
    end
  end

  # GET /storehouses/1/edit
  def edit
    @storehouse = Storehouse.find(params[:id])
  end

  # POST /storehouses
  # POST /storehouses.json
  def create
    @storehouse = Storehouse.new(params[:storehouse])

    respond_to do |format|
      if @storehouse.save
        format.html { redirect_to @storehouse, notice: 'Storehouse was successfully created.' }
        format.json { render json: @storehouse, status: :created, location: @storehouse }
      else
        format.html { render action: "new" }
        format.json { render json: @storehouse.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /storehouses/1
  # PUT /storehouses/1.json
  def update
    @storehouse = Storehouse.find(params[:id])

    respond_to do |format|
      if @storehouse.update_attributes(params[:storehouse])
        format.html { redirect_to @storehouse, notice: 'Storehouse was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @storehouse.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /storehouses/1
  # DELETE /storehouses/1.json
  def destroy
    @storehouse = Storehouse.find(params[:id])
    @storehouse.destroy

    respond_to do |format|
      format.html { redirect_to storehouses_url }
      format.json { head :no_content }
    end
  end
  
  def print_storehouse_out
    @storehouse = Storehouse.find(params[:id])
    @ht = HistoryTracker.find(params[:ht_id])
    @pb = Partbatch.find(@ht.association_chain[0]['id'])
    respond_to do |format|
      format.html { render 'print_ht', layout: false }
      format.json { head :no_content }
    end
  end
end
