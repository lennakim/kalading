class PartbatchesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_default_operator
  
  # GET /partbatches
  # GET /partbatches.json
  def index
    @partbatches = Partbatch.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @partbatches }
    end
  end

  # GET /partbatches/1
  # GET /partbatches/1.json
  def show
    @partbatch = Partbatch.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @partbatch }
    end
  end

  # GET /partbatches/new
  # GET /partbatches/new.json
  def new
    @storehouse = Storehouse.find(params[:storehouse_id])
    @partbatch = @storehouse.partbatches.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @partbatch }
    end
  end

  # GET /partbatches/1/edit
  def edit
    @partbatch = Partbatch.find(params[:id])
    @storehouse = @partbatch.storehouse
  end

  # POST /partbatches
  # POST /partbatches.json
  def create
    self.current_operator = User.find(params[:partbatch][:user_id]) if params[:partbatch][:user_id]
    @storehouse = Storehouse.find(params[:storehouse_id])
    @partbatch = @storehouse.partbatches.new(params[:partbatch])

    respond_to do |format|
      if @partbatch.save
        format.html { redirect_to @storehouse, notice: I18n.t(:partbatch_created) }
        format.json { render json: @partbatch, status: :created, location: @partbatch }
      else
        format.html { render action: "new" }
        format.json { render json: @partbatch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /partbatches/1
  # PUT /partbatches/1.json
  def update
    @partbatch = Partbatch.find(params[:id])

    respond_to do |format|
      if @partbatch.update_attributes(params[:partbatch])
        format.html { redirect_to @partbatch, notice: 'Partbatch was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @partbatch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /partbatches/1
  # DELETE /partbatches/1.json
  def destroy
    @partbatch = Partbatch.find(params[:id])
    @partbatch.destroy

    respond_to do |format|
      format.html { redirect_to partbatches_url }
      format.json { head :no_content }
    end
  end

  # POST /partbatches/1
  def inout
    @partbatch = Partbatch.find(params[:id])
    if params[:back]
      if params[:user][:id] == ''
        @error = I18n.t(:user_id_empty)
      elsif params[:quantity].to_i <=0 || params[:quantity].to_i + @partbatch.remained_quantity > @partbatch.quantity
        @error = I18n.t(:quantity_error, min: 1, max: @partbatch.quantity - @partbatch.remained_quantity )
      end
    else
      if params[:user][:id] == ''
        @error = I18n.t(:user_id_empty)
      elsif params[:quantity].to_i <=0 || params[:quantity].to_i > @partbatch.remained_quantity
        @error = I18n.t(:quantity_error, min: 1, max: @partbatch.remained_quantity )
      end
    end
    return if @error

    self.current_operator = User.find(params[:user][:id])
    @storehouse = @partbatch.storehouse
    if params[:back]
      @partbatch.update_attribute :remained_quantity, @partbatch.remained_quantity + params[:quantity].to_i
    else
      @partbatch.update_attribute :remained_quantity, @partbatch.remained_quantity - params[:quantity].to_i
    end
    @history_trackers = Kaminari.paginate_array(HistoryTracker.where(scope: 'partbatch').desc(:created_at)).page(0).per(5)
  end
end
