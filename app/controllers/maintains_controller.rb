class MaintainsController < ApplicationController
  # GET /maintains
  # GET /maintains.json
  def index
    if params[:car_location] && params[:car_location] != '' && params[:car_num] && params[:car_num] != ''
      @maintains = []
      Order.where(car_location: params[:car_location], car_num: params[:car_num]).each do |o|
	@maintains += o.maintains.desc(:created_at)
      end
    else
      @maintains = Maintain.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json {
        @maintains = Kaminari.paginate_array(@maintains).page(params[:page]).per(params[:per])
      }
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
    if params[:maintain][:wheels_attributes]
      @maintain.wheels.destroy
    end
    if params[:maintain][:lights_attributes]
      @maintain.lights.destroy
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
    create_pic_type = 'create_' + params[:type] + '_pic'
    pic = @maintain.send(create_pic_type, p: params[:pic_data])
    respond_to do |format|
      format.html { head :no_content }
      format.json { render json: {result: 'ok', url: pic.p.url }, status: :ok }
    end
  end
    
  def last_maintain
    curr_maintain = Maintain.find(params[:id])
    @maintain = Maintain.where(order_id: curr_maintain.order_id, :created_at.lt => curr_maintain.created_at).desc(:created_at).first
  end
  
  def auto_inspection_report
    @maintains = Maintain.where(order_id: params[:order_id]).desc(:created_at).page(params[:page]).per(params[:per])
  end
  
  def maintain_summary
    @m = Maintain.find(params[:id])
  end
end
