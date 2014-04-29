class OrdersController < ApplicationController
  before_filter :check_for_mobile, :only => [:order_begin, :choose_service]
  before_filter :authenticate_user!, :except => [
    :uploadpic, :order_begin, :choose_service, :create, :choose_auto_model, :choose_auto_submodel, :pay, :discount_apply, :order_finish, :order_preview, :auto_maintain, :auto_maintain_price, :create_auto_maintain_order, :latest_orders, :create_auto_maintain_order2, :create_auto_verify_order, :create_auto_test_order, :auto_test_price, :auto_test_order, :auto_verify_price, :auto_verify_order ]
  before_filter :set_default_operator
  
  # GET /orders
  # GET /orders.json
  def index
    if params[:state] && params[:state] != ''
      @orders = Order.where(state: params[:state])
    else
      @orders = Order.all
    end

    if params[:car_num] && params[:car_num] != ''
      @orders = @orders.where(car_num: /.*#{params[:car_num]}.*/i)
    end

    if params[:phone_num] && params[:phone_num] != ''
      @orders = @orders.where(phone_num: /.*#{params[:phone_num]}.*/i)
    end

    if params[:customer_name] && params[:customer_name] != ''
      @orders = @orders.where(name: /.*#{params[:customer_name]}.*/i)
    end

    if params[:seq] && params[:seq] != ''
      @orders = @orders.where(seq: params[:seq])
    end

    @orders = @orders.desc(:seq).page params[:page]

    if params[:history]
      @history_trackers = Kaminari.paginate_array(HistoryTracker.where(scope: 'order').desc(:created_at)).page(0).per(5)
    end
    
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
    @auto_submodels = Kaminari.paginate_array([@order.auto_submodel]).page(0) if @order.auto_submodel
    respond_to do |format|
      format.html { render action: "new" }
      format.json { render action: "new", json: @order }
    end
  end

  # GET /orders/1/edit
  def edit
    session[:return_to] ||= request.referer
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
    d = Discount.find_by token: @order.discount_num
    if d && d.expire_date >= Date.today && d.orders.count < d.times
      @order.discounts << d
    end
    @order.state = 2
    respond_to do |format|
      if @order.save
        Auto.find_or_create_by(car_location: @order.car_location, car_num: @order.car_num, auto_submodel_id: @order.auto_submodel.id ) if @order.auto_submodel
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
    elsif params[:edit_all]
      notice = I18n.t(:order_saved_notify, seq: @order.seq)
    else
      params[:order][:state] = 1
      case @order.state
      when 0..1
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
          d = Discount.find_by token: params[:order][:discount_num]
          if d && d.expire_date >= Date.today && d.orders.count < d.times
            @order.discounts << d
          end
        end
        format.html { redirect_to session.delete(:return_to), notice: notice }
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
    d = Discount.find_by token: @order.discount_num
    if d && d.expire_date >= Date.today && d.orders.count < d.times
      @order.discounts << d
    end
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @order }
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
  
  def latest_orders
    @orders = Order.desc(:created_at).limit(14)
  end

  def auto_maintain
    return render json: { result: t(:auto_submodel_required)}, status: :bad_request if params[:asm_id].nil?
    asm = AutoSubmodel.find(params[:asm_id])
    return render json: { result: t(:auto_submodel_required)}, status: :bad_request if asm.nil?
    @order = Order.new
    @order.auto_submodel = asm
    maintain_service = ServiceType.find '527781377ef560ccbc000003'
    return render json: t(:auto_maintain_service_type_not_found), status: :bad_request if maintain_service.nil?
    @order.service_types << maintain_service
    asm.parts_by_type.each do |t, parts|
      if t.name == I18n.t(:engine_oil)
        parts.group_by(&:spec)[parts.first.spec].each do |p|
          @order.parts << p
          @order.part_counts[p.id.to_s] = asm.cals_part_count(p)
        end
      else
        @order.parts << parts.first
        @order.part_counts[parts.first.id.to_s] = asm.cals_part_count(parts.first)
      end
    end
  end

  def auto_maintain_packs
    @asms = []
    @asms = AutoSubmodel.where(data_source: 2, service_level: 1).where(:oil_filter_count.gt => 0, :air_filter_count.gt => 0, :cabin_filter_count.gt => 0).asc(:full_name_pinyin)
    @asms_count = @asms.count
    respond_to do |format|
      format.html {
        @asms = @asms.page(params[:page]).per(10)
        @packs = []
        @asms.each do |asm|
          params[:asm_id] = asm.id.to_s
          auto_maintain
          @packs << @order
        end
      }
      format.csv {
        csv = CSV.generate({}) do |csv|
          csv << ['ID', I18n.t(:owner_auto_brand), I18n.t(:series), I18n.t(:auto_submodel), I18n.t(:total_price_with_st)]
          @asms.each do |asm|
            params[:asm_id] = asm.id.to_s
            auto_maintain
            csv << [@order.auto_submodel.id, @order.auto_submodel.auto_model.auto_brand.name, @order.auto_submodel.auto_model.name, @order.auto_submodel.full_name, @order.calc_price ]
          end
        end
        headers['Last-Modified'] = Time.now.httpdate
        send_data csv, :filename => 'maintain_packs' + I18n.l(DateTime.now) + '.csv'
      }
    end
  end
  
  def auto_maintain_price
    _create_auto_maintain_order
    render :action => "auto_maintain"
  end
  
  def create_auto_maintain_order
    return render json: { result: t(:auto_submodel_required)}, status: :bad_request if params[:asm_id].nil?
    return render json: {result: t(:parts_needed)}, status: :bad_request if params[:parts].nil? || params[:parts].empty?
    return render json: {result: t(:info_needed)}, status: :bad_request if params[:info].nil?
    return render json: {result: t(:address_needed)}, status: :bad_request if params[:info][:address].nil? || params[:info][:address].empty?
    return render json: {result: t(:name_needed)}, status: :bad_request if params[:info][:name].nil? || params[:info][:name].empty?
    return render json: {result: t(:phone_num_needed)}, status: :bad_request if params[:info][:phone_num].nil? || params[:info][:phone_num].empty?
    return render json: {result: t(:car_location_needed)}, status: :bad_request if params[:info][:car_location].nil? || params[:info][:car_location].empty?
    return render json: {result: t(:car_num_needed)}, status: :bad_request if params[:info][:car_num].nil? || params[:info][:car_num].empty?
    asm = AutoSubmodel.find(params[:asm_id])
    return render json: t(:auto_submodel_required), status: :bad_request if asm.nil?
    
    _create_auto_maintain_order
    return render json: {result: t(:parts_needed)}, status: :bad_request if @order.parts.empty?

    @order.update_attributes params[:info]
    @order.car_num.upcase!
    @order.save!
    render json: {result: 'succeeded', seq: @order.seq }
  end

  # no auto submodel, no parts
  def create_auto_maintain_order2
    return render json: {result: t(:info_needed)}, status: :bad_request if params[:info].nil?
    return render json: {result: t(:address_needed)}, status: :bad_request if params[:info][:address].nil? || params[:info][:address].empty?
    return render json: {result: t(:name_needed)}, status: :bad_request if params[:info][:name].nil? || params[:info][:name].empty?
    return render json: {result: t(:phone_num_needed)}, status: :bad_request if params[:info][:phone_num].nil? || params[:info][:phone_num].empty?
    return render json: {result: t(:car_location_needed)}, status: :bad_request if params[:info][:car_location].nil? || params[:info][:car_location].empty?
    return render json: {result: t(:car_num_needed)}, status: :bad_request if params[:info][:car_num].nil? || params[:info][:car_num].empty?
    
    _create_auto_maintain_order
    if @order.parts.empty?
      @order.buymyself = true
    end
    @order.update_attributes params[:info]
    @order.car_num.upcase!
    @order.save!
    render json: {result: 'succeeded', seq: @order.seq }
  end

  def create_auto_verify_order
    return render json: {result: t(:info_needed)}, status: :bad_request if params[:info].nil?
    return render json: {result: t(:address_needed)}, status: :bad_request if params[:info][:address].nil? || params[:info][:address].empty?
    return render json: {result: t(:name_needed)}, status: :bad_request if params[:info][:name].nil? || params[:info][:name].empty?
    return render json: {result: t(:phone_num_needed)}, status: :bad_request if params[:info][:phone_num].nil? || params[:info][:phone_num].empty?
    return render json: {result: t(:car_location_needed)}, status: :bad_request if params[:info][:car_location].nil? || params[:info][:car_location].empty?
    return render json: {result: t(:car_num_needed)}, status: :bad_request if params[:info][:car_num].nil? || params[:info][:car_num].empty?
    @order = Order.new
    st = ServiceType.find '52cb67839a94e4fd190001eb'
    return render json: t(:auto_verify_service_type_not_found), status: :bad_request if st.nil?
    @order.service_types << st
    check_discount
    @order.update_attributes params[:info]
    @order.car_num.upcase!
    @order.save!
    render json: {result: 'succeeded', seq: @order.seq }
  end

  def create_auto_test_order
    return render json: {result: t(:info_needed)}, status: :bad_request if params[:info].nil?
    return render json: {result: t(:address_needed)}, status: :bad_request if params[:info][:address].nil? || params[:info][:address].empty?
    return render json: {result: t(:name_needed)}, status: :bad_request if params[:info][:name].nil? || params[:info][:name].empty?
    return render json: {result: t(:phone_num_needed)}, status: :bad_request if params[:info][:phone_num].nil? || params[:info][:phone_num].empty?
    return render json: {result: t(:car_location_needed)}, status: :bad_request if params[:info][:car_location].nil? || params[:info][:car_location].empty?
    return render json: {result: t(:car_num_needed)}, status: :bad_request if params[:info][:car_num].nil? || params[:info][:car_num].empty?
    @order = Order.new
    st = ServiceType.find '52c186d4098e7133cd000005'
    return render json: t(:auto_test_service_type_not_found), status: :bad_request if st.nil?
    @order.service_types << st
    check_discount
    @order.update_attributes params[:info]
    @order.car_num.upcase!
    @order.save!
    render json: {result: 'succeeded', seq: @order.seq }
  end
    
  def auto_test_price
    @order = Order.new
    st = ServiceType.find '52c186d4098e7133cd000005'
    return render json: t(:auto_test_service_type_not_found), status: :bad_request if st.nil?
    @order.service_types << st
    check_discount
    render :action => 'auto_test_order'
  end

  def auto_test_order
    auto_test_price
  end
  
  def auto_verify_price
    @order = Order.new
    st = ServiceType.find '52cb67839a94e4fd190001eb'
    return render json: t(:auto_verify_service_type_not_found), status: :bad_request if st.nil?
    @order.service_types << st
    check_discount
    render :action => 'auto_verify_order'
  end

  def auto_verify_order
    auto_verify_price
  end
    
private
  def _create_auto_maintain_order
    @order = Order.new
    if params[:asm_id]
      asm = AutoSubmodel.find(params[:asm_id])
      @order.auto_submodel = asm
    end
    maintain_service = ServiceType.find '527781377ef560ccbc000003'
    return render json: t(:auto_maintain_service_type_not_found), status: :bad_request if maintain_service.nil?
    @order.service_types << maintain_service
    if params[:parts]
      params[:parts].each do |h|
        parts = []
        p = Part.find h[:number]
        parts << p if p
        if parts.empty?
          # For engine oil
          parts = Part.where part_brand: (PartBrand.find_by name: h[:brand]), spec: h[:number]
        end
        parts.each do |p|
          @order.parts << p
          @order.part_counts[p.id.to_s] = asm.cals_part_count(p)
        end
      end
    end
    check_discount
  end

  def check_discount
    if params[:discount]
      discount = Discount.find params[:discount]
      if discount
        if discount.expire_date < Date.today
          @discount_error = I18n.t(:discount_expired, s: (I18n.l discount.expire_date ) )
        elsif discount.orders.count >= discount.times
          @discount_error = I18n.t(:discount_no_capacity)
        else
          @order.discounts << discount
        end
      else
        @discount_error = I18n.t(:discount_not_exist)
      end
    end
  end
end
