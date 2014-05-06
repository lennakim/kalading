class StorehousesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_default_operator
  load_and_authorize_resource :except => [:import]

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
    @part_to_partbatches = Kaminari.paginate_array(pbs.group_by(&:part).to_a.sort_by {|x, y| x.number }).page(params[:page]).per(15)

    respond_to do |format|
      format.html {
        #@history_trackers = Kaminari.paginate_array(HistoryTracker.where(scope: 'partbatch').desc(:created_at)).page(0).per(5)
        @history_trackers = Kaminari.paginate_array([]).page(0).per(5)
      }
      format.js # show.js.erb
      format.json { render json: pbs }
      format.csv {
        headers['Last-Modified'] = Time.now.httpdate
        send_data @storehouse.to_csv, :filename => @storehouse.name + I18n.l(DateTime.now) + '.csv'
      }
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
    if params[:part]
      @part = Part.find params[:part]
      @partbatches = @storehouse.partbatches.where(part: @part)
    end
  end

  def inout
    @storehouse = Storehouse.find(params[:id])
    @part = Part.find params[:part]
    @partbatches = @storehouse.partbatches.where(part: @part).asc(:created_at)
    @quantity = params[:quantity].to_i
    if params[:back]
      if params[:user][:id] == ''
        @error = I18n.t(:user_id_empty)
      elsif @quantity <=0 || @quantity + (@partbatches.sum {|x| x.remained_quantity}) > (@partbatches.sum {|x| x.quantity})
        @error = I18n.t(:quantity_error, min: 1, max: (@partbatches.sum {|x| x.quantity - x.remained_quantity}) )
      end
    else
      if params[:user][:id] == ''
        @error = I18n.t(:user_id_empty)
      elsif @quantity <= 0 || @quantity > (@partbatches.sum {|x| x.remained_quantity})
        @error = I18n.t(:quantity_error, min: 1, max: ((@partbatches.sum {|x| x.remained_quantity})) )
      end
    end
    return if @error

    self.current_operator = User.find(params[:user][:id])
    if params[:back]
      need_q = @quantity
      @partbatches.each do |pb|
        c = [need_q, pb.quantity - pb.remained_quantity].min
        pb.update_attribute :remained_quantity, pb.remained_quantity + c
        pb.part.auto_submodels.each do |asm|
          asm.on_part_inout pb.part, c
        end
        need_q -= c
        break if need_q <= 0
      end
    else
      need_q = @quantity
      @partbatches.each do |pb|
        c = [need_q, pb.remained_quantity].min
        pb.update_attribute :remained_quantity, pb.remained_quantity - c
        pb.part.auto_submodels.each do |asm|
          asm.on_part_inout pb.part, -c
        end
        need_q -= c
        break if need_q <= 0
      end
    end
    @history_trackers = Kaminari.paginate_array(HistoryTracker.where(scope: 'partbatch').desc(:created_at)).page(0).per(5)
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
  
  def import
    part_brand = PartBrand.find_by name: /.*#{params[I18n.t(:part_brand)]}.*/
    return render json: "#{params[I18n.t(:part_brand)]} not found" if part_brand.nil?
    part_type = PartType.find_by name: /.*#{params[I18n.t(:class)]}.*/
    return render json: "#{params[I18n.t(:class)]} not found" if part_type.nil?
    sh = Storehouse.find_by name: /.*#{params[I18n.t(:storehouse)]}.*/
    return render json: "#{params[I18n.t(:storehouse)]} not found" if sh.nil?
    u = User.find_by phone_num: '13384517937'
    return render json: "user not found" if u.nil?

    part = Part.find_or_create_by number: params[I18n.t(:number)], part_brand_id: part_brand.id, part_type_id: part_type.id
    supplier = Supplier.find_by name: /.*#{params[I18n.t(:part_supplier)]}.*/
    supplier = Supplier.create name: params[I18n.t(:part_supplier)] if supplier.nil?
    price = 0.0
    price = params[I18n.t(:buy_price)].to_f if params[I18n.t(:buy_price)]
    
    sh.partbatches.create part_id: part.id,
      supplier_id: supplier.id,
      price: price,
      quantity: 100,
      remained_quantity: 100,
      user_id: u.id
    return render json: 'ok'
  end
end
