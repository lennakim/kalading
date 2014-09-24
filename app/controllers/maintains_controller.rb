class MaintainsController < ApplicationController
  # GET /maintains
  # GET /maintains.json
  def index
    if params[:car_location].present? && params[:car_num].present?
      @maintains = []
      Order.where(car_location: params[:car_location], car_num: params[:car_num]).each do |o|
	@maintains += o.maintains.desc(:created_at)
      end
    else
      @maintains = []
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

  # convert string array to integer array
  def array_convert(a)
    temp = Array.new
    a.each do |s|
      temp.push(s.to_i)
    end
    temp
  end
  
  def normalize_params(params)
    if params[:maintain][:wheels_attributes]
      params[:maintain][:wheels_attributes].each do |k, w|
        if !w[:tread_desc].nil?
          w[:tread_desc].reject!(&:blank?)
          w[:tread_desc] = array_convert w[:tread_desc]
        end
        if !w[:sidewall_desc].nil?
          w[:sidewall_desc].reject!(&:blank?) 
          w[:sidewall_desc] = array_convert w[:sidewall_desc]
        end
        if !w[:brake_disc_desc].nil?
          w[:brake_disc_desc].reject!(&:blank?) 
          w[:brake_disc_desc] = array_convert w[:brake_disc_desc]
        end
      end
    end
    if params[:maintain][:lights_attributes]
      params[:maintain][:lights_attributes].each do |k, l|
        if !l[:desc].nil?
          l[:desc].reject!(&:blank?)
          l[:desc] = array_convert l[:desc]
        end  
      end
    end
  end

  # POST /maintains
  # POST /maintains.json
  def create
    if params[:order_seq]
      normalize_params(params)
    end
    @maintain = Maintain.new(params[:maintain])
    respond_to do |format|
      if @maintain.save
        format.html { redirect_to @maintain, notice: I18n.t(:maintain_created) }
        format.json { render json: {id: @maintain.id} }
      else
        format.html { render action: "new", notice: I18n.t(:maintain_not_created) }
        format.json { render json: @maintain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /maintains/1
  # PUT /maintains/1.json
  def update
    @maintain = Maintain.find(params[:id])
    if params[:order_seq]
      normalize_params(params)
    end
    
    if params[:maintain][:wheels_attributes]
      @maintain.wheels.destroy
    end
    if params[:maintain][:lights_attributes]
      @maintain.lights.destroy
    end

    respond_to do |format|
      if @maintain.update_attributes(params[:maintain])
        format.html { redirect_to @maintain, notice: I18n.t(:maintain_updated) }
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
    pic_type = params[:type] + '_pics'
    pic = @maintain.send(pic_type).create!(p: params[:pic_data])
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
    @maintains = []
    if params[:order_id].present?
      @maintains = Maintain.where(order_id: params[:order_id]).desc(:created_at).page(params[:page]).per(params[:per])
    elsif params[:phone_nums].present? || !params[:login_phone_num].blank? || !params[:client_id].blank?
      if params[:phone_nums].present?
	orders = Order.any_in(phone_num: params[:phone_nums])
      end
      if !params[:login_phone_num].blank? && !params[:client_id].blank?
	phone_num = params[:login_phone_num]
	orders = Order.any_of({login_phone_num: phone_num}, {phone_num: phone_num}, {client_id: params[:client_id]})
      end
      if !params[:login_phone_num].blank? && params[:client_id].blank?
	phone_num = params[:login_phone_num]
	orders = Order.any_of({login_phone_num: phone_num}, {phone_num: phone_num})
      end
      if params[:login_phone_num].blank? && !params[:client_id].blank?
	orders = Order.where(client_id: params[:client_id])
      end
      orders.where(:state.gte => 5,:state.lte => 7).desc(:seq).each do |o|
	@maintains += o.maintains.desc(:created_at)
      end
      @maintains = Kaminari.paginate_array(@maintains).page(params[:page]).per(params[:per])
    end
  end
  
  def maintain_summary
    @m = Maintain.find(params[:id])
  end
end
