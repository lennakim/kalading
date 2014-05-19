class MaintainsController < ApplicationController
  # GET /maintains
  # GET /maintains.json
  def index
    if params[:car_location] && params[:car_location] != '' && params[:car_num] && params[:car_num] != ''
      order = Order.where(car_location: params[:car_location], car_num: params[:car_num])
      if order
        @maintains = Maintain.where(order_id: order.id)
      end
    else
      @maintains = Maintain.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @maintains }
    end
  end

  # GET /maintains/1
  # GET /maintains/1.json
  def show
    @maintain = Maintain.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @maintain }
    end
  end

  # GET /maintains/new
  # GET /maintains/new.json
  def new
    @maintain = Maintain.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @maintain }
    end
  end

  # GET /maintains/1/edit
  def edit
    @maintain = Maintain.find(params[:id])
  end

  # POST /maintains
  # POST /maintains.json
  def create
    @maintain = Maintain.new(params[:maintain])

    respond_to do |format|
      if @maintain.save
        format.html { redirect_to @maintain, notice: 'Maintain was successfully created.' }
        format.json { render json: {id: @maintain.id} }
      else
        format.html { render action: "new" }
        format.json { render json: @maintain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /maintains/1
  # PUT /maintains/1.json
  def update
    @maintain = Maintain.find(params[:id])

    if params[:maintain][:wheels]
      params[:maintain][:wheels].each do |wheel_data|
        @maintain.wheels.create!(wheel_data)
      end
      return render json: {result: 'ok'}
    end
    respond_to do |format|
      if @maintain.update_attributes(params[:maintain])
        format.html { redirect_to @maintain, notice: 'Maintain was successfully updated.' }
        format.json { render json: {result: 'ok'} }
      else
        format.html { render action: "edit" }
        format.json { render json: { result: @order.errors[0] } }
      end
    end
  end

  # DELETE /maintains/1
  # DELETE /maintains/1.json
  def destroy
    @maintain = Maintain.find(params[:id])
    @maintain.destroy

    respond_to do |format|
      format.html { redirect_to maintains_url }
      format.json { head :no_content }
    end
  end

  def uploadpic
    @maintain = Maintain.find(params[:id])
    pic_type = params[:type] + '_pic'
    pic = @maintain.send(pic_type).create!(p: params[:pic_data])
    respond_to do |format|
      format.html { head :no_content }
      format.json { render json: {result: 'ok', url: pic.p.url }, status: :ok }
    end
  end
    
  def last_maintain
    curr_maintain = Maintain.find(params[:id])
    order_id = curr_maintain.order_id
    create_time = curr_maintain.created_at
    @maintain = Maintain.where(order_id: order_id, :created_at.lt => create_time).desc(:created_at).first
  end
end
