class OrdersController < ApplicationController
  before_filter :check_for_mobile, :only => [:new, :edit, :index, :show]
  before_filter :authenticate_user!
  before_filter :set_default_operator

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all.page params[:page]

    @order = Order.new
    @order.auto = Auto.first
    @order.auto.users << User.first
    @order.customer = User.first
    ServiceType.all.each do |st|
      @order.service_items.build(service_type_id: st.id)
    end
    @order.discounts << Discount.first
    
    respond_to do |format|
      format.html # index.html.erb
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
    @order.auto = Auto.first
    @order.auto.users << User.first
    @order.customer = User.first
    ServiceType.all.each do |st|
      @order.service_items.build(service_type_id: st.id, price: st.sell_prices.last.price)
    end
    @order.discounts << Discount.first
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(params[:order])

    respond_to do |format|
      if @order.save
        format.html { redirect_to orders_url, notice: 'Order was successfully created.' }
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
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(params[:order])
        format.html { redirect_to orders_url, notice: 'Order was successfully updated.' }
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
end
