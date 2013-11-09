class OrdersController < ApplicationController
  before_filter :check_for_mobile, :only => [:order, :order2]
  before_filter :authenticate_user!,  :except => [:uploadpic] if !Rails.env.importdata?
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
    @order.auto_submodel = AutoBrand.first.auto_models.first.auto_submodels.first
    @submodel = @order.auto_submodel
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
    @submodel = @order.auto_submodel
    respond_to do |format|
      format.html { render action: "new" }
      format.json { render action: "new", json: @order }
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
    @order.discount_num = @order.discounts.first.id if @order.discounts.exists?
    @submodel = @order.auto_submodel
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @order }
    end
  end

  # POST /orders
  # POST /orders.json
  def create
    params[:order][:car_num].upcase! if params[:order][:car_num]
    @order = Order.new(params[:order])
    @order.discounts << Discount.find(@order.discount_num)
    respond_to do |format|
      if @order.save
        Auto.find_or_create_by(car_location: params[:order][:car_location], car_num: params[:order][:car_num], auto_submodel_id: @order.auto_submodel.id )
        format.html { redirect_to orders_url, notice: I18n.t(:order_created, seq: @order.seq) }
        format.json { render json: @order, status: :created, location: @order }
      else
        format.html { render action: "new" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
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
    @submodel = AutoSubmodel.find(params[:model])
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
    @order = Order.new
    @order.auto_submodel = AutoSubmodel.find(session[:auto_m_id]) if session[:auto_m_id]
    @order.car_location = session[:car_l] if session[:car_l]
    @order.car_num = session[:car_n] if session[:car_n]
  end

  def order
    init_order_from_session
    @order.auto_submodel = AutoBrand.first.auto_models.first.auto_submodels.first if @order.auto_submodel.nil?
  end
  
  def order2
    @order = Order.new
    @order.auto_submodel = AutoSubmodel.find(params[:order][:auto_submodel])
    @order.car_location = params[:order][:car_location]
    @order.car_num = params[:order][:car_num]
    session[:auto_m_id] = params[:order][:auto_submodel_id]
    session[:car_l] = params[:order][:car_location]
    session[:car_n] = params[:order][:car_num]
  end
end
