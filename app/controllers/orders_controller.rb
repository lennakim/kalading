class OrdersController < ApplicationController
  before_filter :check_for_mobile, :only => [:order_begin, :choose_service]
  before_filter :authenticate_user!, :except => [:uploadpic, :order_begin, :choose_service, :create, :choose_auto_model, :choose_auto_submodel, :pay, :discount_apply, :order_finish, :order_preview] if !Rails.env.importdata?
  before_filter :set_default_operator
  
  # GET /orders
  # GET /orders.json
  def index
    if params[:state]
      @orders = Order.where(state: params[:state]).asc(:seq).page params[:page]
    elsif params[:car_location] && params[:car_num]
      params[:car_num].upcase!
      @orders = Order.where(car_location: params[:car_location], car_num: params[:car_num]).asc(:created_at).page params[:page]
    elsif params[:phone_num]
      @orders = Order.where(phone_num: params[:phone_num]).asc(:created_at).page params[:page]
    else
      @orders = Order.asc(:seq).page params[:page]
    end

    @history_trackers = Kaminari.paginate_array(HistoryTracker.where(scope: 'order').desc(:created_at)).page(0).per(5)
    
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @orders }
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      if params[:mobilejs]
        format.js { render :action => "show.js.erb" }
      end
      format.html # show.html.erb
      format.js
      format.json { render json: @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.json
  def new
    @order = Order.new
    @order.serve_datetime = DateTime.now.since(1.days)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
  end

  def duplicate
    o = Order.find(params[:id])
    @order = o.clone
    @order.state = 0
    @order.serve_datetime = DateTime.now.since(1.days)
    @order.discounts = nil
    @order.calc_price
    @auto_submodel = @order.auto_submodel
    @auto_submodels = [@order.auto_submodel] if @order.auto_submodel
    respond_to do |format|
      format.html { render action: "new" }
      format.json { render action: "new", json: @order }
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
    authorize! :edit_all, @order if params[:edit_all]
    @order.discount_num = @order.discounts.first.id if @order.discounts.exists?
    @auto_submodel = @order.auto_submodel
    @auto_submodels = Kaminari.paginate_array([@order.auto_submodel]).page(0) if @order.auto_submodel
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @order }
    end
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(params[:order])
    if params[:use_session]
      init_order_from_session
      save_order_to_session
    end
    @order.car_num.upcase!
    @order.discounts << Discount.find(@order.discount_num)
    respond_to do |format|
      if @order.save
        Auto.find_or_create_by(car_location: @order.car_location, car_num: @order.car_num, auto_submodel_id: @order.auto_submodel.id )
        format.html { redirect_to orders_url, notice: I18n.t(:order_created, seq: @order.seq) }
        format.json { render json: @order, status: :created, location: @order }
        format.mobile { render  :action => "show.mobile.erb"}
      else
        format.html { render action: "new" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
        format.mobile { return render json: t(:order_create_failed), status: :bad_request }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.json
  def update
    params[:order][:car_num].upcase! if params[:order][:car_num]
    @order = Order.find(params[:id])
    if params[:verify_failed]
      params[:order][:state] = 1
      notice = I18n.t(:order_verify_failed, seq: @order.seq)
    else
      params[:order][:state] = 1
      case @order.state
      when 0
        params[:order][:state] = 2
        notice = I18n.t(:order_verified_notify, seq: @order.seq)
      when 2
        u = User.find(params[:order][:engineer_id])
        params[:order][:state] = 3
        notice = I18n.t(:order_assigned_notify, seq: @order.seq, name: u.name)
      when 3
        params[:order][:state] = 4
        notice = I18n.t(:order_scheduled_notify, seq: @order.seq)
      when 4
        params[:order][:state] = 5
        notice = I18n.t(:order_served_notify, seq: @order.seq)
      when 5
        params[:order][:state] = 6
        notice = I18n.t(:order_handovered_notify, seq: @order.seq)
      when 6
        params[:order][:state] = 7
        notice = I18n.t(:order_revisited_notify, seq: @order.seq)
      else
        notice = I18n.t(:order_saved_notify, seq: @order.seq)
      end
    end
    
    respond_to do |format|
      if @order.update_attributes(params[:order])
        if params[:order][:discount_num]
          @order.discounts = nil
          @order.discounts << Discount.find(params[:order][:discount_num])
        end
        if params[:verify_failed]
          format.html { redirect_to orders_url(state: 0), notice: notice }
        else
          format.html { redirect_to orders_url(state: params[:order][:state] - 1), notice: notice }
        end
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :no_content }
    end
  end
  
  def uploadpic
    @order = Order.find(params[:id])
    pic = @order.pictures.create!(p: params[:pic_data])
    respond_to do |format|
      format.html { head :no_content }
      format.json { render json: {result: 'ok', url: pic.p.url }, status: :ok }
    end
  end
  
  def query_parts
    @auto_submodel = AutoSubmodel.find(params[:model])
    respond_to do |format|
      format.html
      format.js
      format.json { head :no_content }
    end
  end
  
  def calcprice
    @order = Order.new(params[:order])
    @order.discounts << Discount.find(@order.discount_num)
    respond_to do |format|
      format.html
      format.js
      format.json { head :no_content }
    end
  end

  def history
    @history_trackers = Kaminari.paginate_array(HistoryTracker.where(scope: 'order').desc(:created_at)).page(params[:pagina]).per(5)
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @history_trackers }
    end
  end
 
  def init_order_from_session
    @order ||= Order.new
    @order.auto_submodel = AutoSubmodel.find(session[:auto_m_id]) if session[:auto_m_id]
    @order.car_location = session[:car_l] if session[:car_l]
    @order.car_num = session[:car_n] if session[:car_n]
    @order.service_type_ids = session[:svc_type_ids] if session[:svc_type_ids]
    @order.serve_datetime = session[:serve_datetime] if session[:serve_datetime]
    @order.address = session[:address] if session[:address]
    @order.phone_num = session[:phone_num] if session[:phone_num]
    @order.name = session[:name] if session[:name]
    @order.pay_type = session[:pay_type] if session[:pay_type]
    @order.reciept_type = session[:reciept_type] if session[:reciept_type]
    @order.reciept_title = session[:reciept_title] if session[:reciept_title]
    @order.part_ids = session[:part_ids] if session[:part_ids]
  end

  def save_order_to_session
    session[:auto_m_id] = @order.auto_submodel.id if @order.auto_submodel
    session[:car_l] = @order.car_location if @order.car_location
    session[:car_n] =  @order.car_num if @order.car_num 
    session[:svc_type_ids] =  @order.service_type_ids
    session[:address] =  @order.address if @order.address
    session[:phone_num] =  @order.phone_num if @order.phone_num
    session[:name] =  @order.name if @order.name
    session[:serve_datetime] =  @order.serve_datetime if @order.serve_datetime
    session[:pay_type] =  @order.pay_type if @order.pay_type
    session[:reciept_type] =  @order.reciept_type if @order.reciept_type
    session[:reciept_title] =  @order.reciept_title if @order.reciept_title
    session[:part_ids] =  @order.part_ids
  end

  def order_begin
    init_order_from_session
    @order.auto_submodel = AutoSubmodel.find(params[:auto_submodel]) if params[:auto_submodel]
  end
  
  def choose_service
    init_order_from_session
    if params[:order]
      @order.car_location = params[:order][:car_location] if params[:order][:car_location]
      @order.car_num = params[:order][:car_num] if params[:order][:car_num]
      @order.auto_submodel = AutoSubmodel.find(params[:order][:auto_submodel]) if params[:order][:auto_submodel]
    end
    save_order_to_session
    if @order.car_num.length != 6
      return render json: t(:car_num_required), status: :bad_request
    end

    if params[:choose_auto_brand]
      return render 'choose_auto_brand'
    end
  end

  def choose_auto_model
    @auto_brand = AutoBrand.find params[:auto_brand]
  end

  def choose_auto_submodel
    @auto_model = AutoModel.find params[:auto_model]
  end

  def pay
    init_order_from_session
    @order.service_type_ids = nil if params[:service_only]
    @order.service_type_ids = params[:order][:service_type_ids] if params[:order] && params[:order][:service_type_ids]
    @order.part_ids = params[:order][:part_ids] if params[:order] && params[:order][:part_ids]
    @order.part_ids = nil if params[:service_only]
    save_order_to_session
    if @order.service_type_ids.empty?
      return render json: t(:service_type_at_least_one), status: :bad_request
    end

    if params[:choose_parts]
      return render 'choose_parts'
    end
  end
  
  def discount_apply
    init_order_from_session
    @discount = Discount.find params[:discount]
    @order.discounts << @discount if @discount
  end
  
  def order_preview
    init_order_from_session
    if params[:order]
      @order.phone_num = params[:order][:phone_num]
      @order.name = params[:order][:name]
      @order.address = params[:order][:address]
      @order.serve_datetime = params[:order][:serve_datetime]
    end
    save_order_to_session
    if @order.phone_num.length <= 0
      return render json: t(:phone_num_required), status: :bad_request
    end
    if @order.address.length <= 0
      return render json: t(:address_required), status: :bad_request
    end
  end

  def order_finish
    init_order_from_session
    if params[:order]
      @order.discount_num = params[:order][:discount_num]
      @order.pay_type = params[:order][:pay_type]
      @order.reciept_type = params[:order][:reciept_type]
      @order.reciept_title = params[:order][:reciept_title]
    end
    @order.serve_datetime = DateTime.now.since(1.days) if !@order.serve_datetime
    save_order_to_session
  end
end
