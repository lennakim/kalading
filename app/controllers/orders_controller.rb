class OrdersController < ApplicationController
  before_filter :check_for_mobile, :only => [:index, :order_begin, :choose_service]
  @except_actions = [
    :index, :update, :uploadpic, :order_begin, :choose_service, :create, :choose_auto_model, :choose_auto_submodel, :pay, :discount_apply, :order_finish, :order_preview, :auto_maintain, :auto_maintain_price, :create_auto_maintain_order, :latest_orders, :create_auto_maintain_order2, :create_auto_verify_order, :create_auto_test_order, :auto_test_price, :auto_test_order, :auto_verify_price, :auto_verify_order, :tag_stats, :evaluation_list
  ]
  before_filter :authenticate_user!, :except => @except_actions
  before_filter :set_default_operator
  load_and_authorize_resource :except => @except_actions + [:auto_maintain_query, :create_auto_maintain_order3, :create_auto_maintain_order4]

  # GET /orders
  # GET /orders.json
  def index
    if current_user
      if current_user.roles.empty?
        authorize! :read, Order
      elsif current_user.roles.include? '5'
        @orders = Order.where(:engineer => current_user)
      else
        @orders = Order.all
      end
    else
      if request.format.json?
        return render json: t(:phone_num_needed), status: :bad_request if params[:login_phone_num].blank? && params[:client_id].blank? && params[:phone_nums].blank?
        @orders = Order.all
      else
        return redirect_to new_user_session_url
      end
    end
    
    if !params[:state].blank?
      @orders = @orders.where(state: params[:state])
    end

    if params[:states].present?
      @orders = @orders.any_of(params[:states].collect { |x| {state: x.to_i} } )
    end

    if !params[:part_deliver_state].blank?
      @orders = @orders.where(part_deliver_state: params[:part_deliver_state])
    end

    if !params[:engineer].blank?
      e = User.find params[:engineer]
      @orders = @orders.any_of({engineer: e}, {engineer2: e})
    end

    if !params[:dispatcher].blank?
      e = User.find params[:dispatcher]
      @orders = @orders.where dispatcher: e
    end

    if !params[:car_num].blank?
      @orders = @orders.where(car_num: /.*#{params[:car_num]}.*/i)
    end

    if !params[:phone_num].blank?
      @orders = @orders.where(phone_num: /.*#{params[:phone_num]}.*/i)
    end

    if params[:phone_nums].present?
      @orders = @orders.any_in(phone_num: params[:phone_nums])
    end

    if !params[:customer_name].blank?
      @orders = @orders.where(name: /.*#{params[:customer_name]}.*/i)
    end

    if !params[:address].blank?
      @orders = @orders.where(address: /.*#{params[:address]}.*/i)
    end

    if !params[:seq].blank?
      @orders = @orders.where(seq: params[:seq])
    end

    if !params[:user_type].blank?
      @orders = @orders.where(user_type: UserType.find(params[:user_type]))
    end

    if params[:serve_datetime_start].present?
      sds = Date.parse params[:serve_datetime_start]
      @orders = @orders.where :serve_datetime.gte => sds.beginning_of_day
    end

    if params[:serve_datetime_end].present?
      sds = Date.parse params[:serve_datetime_end]
      @orders = @orders.where :serve_datetime.lte => sds.end_of_day
    end

    if params[:created_at_start].present?
      sds = Date.parse params[:created_at_start]
      @orders = @orders.where :created_at.gte => sds.beginning_of_day
    end

    if params[:created_at_end].present?
      sds = Date.parse params[:created_at_end]
      @orders = @orders.where :created_at.lte => sds.end_of_day
    end

    if !params[:city].blank?
      @orders = @orders.where(city: City.find(params[:city]))
    end

    if params[:history]
      @history_trackers = Kaminari.paginate_array(HistoryTracker.where(scope: 'order').desc(:created_at)).page(0).per(5)
    end
    
    if !params[:login_phone_num].blank? && !params[:client_id].blank?
      phone_num = params[:login_phone_num]
      @orders = @orders.any_of({login_phone_num: phone_num}, {phone_num: phone_num}, {client_id: params[:client_id]})
    end

    if !params[:login_phone_num].blank? && params[:client_id].blank?
      phone_num = params[:login_phone_num]
      @orders = @orders.any_of({login_phone_num: phone_num}, {phone_num: phone_num})
    end

    if params[:login_phone_num].blank? && !params[:client_id].blank?
      @orders = @orders.where(client_id: params[:client_id])
    end

    if params[:auto_submodel].present?
      @orders = @orders.where auto_submodel_id: params[:auto_submodel]
    end

    respond_to do |format|
      format.html {
        params[:per] ||= 20
        params[:per] = @orders.count if (params[:state].to_i == 2 && params[:serve_datetime_start].present? && params[:serve_datetime_start] == params[:serve_datetime_end])
        @orders = @orders.desc(:seq).page(params[:page]).per(params[:per])
        if params[:states]
          render layout: 'storehouses'
        end
      }
      format.json {
        params[:page] ||= 1
        params[:per] ||= 5
        @orders = @orders.desc(:seq).page(params[:page]).per(params[:per])
      }
      format.csv {
        csv = CSV.generate({}) do |csv|
          csv << ['ID', I18n.t(:name), I18n.t(:auto_owner_name), I18n.t(:address), I18n.t(:car_number), I18n.t(:auto_submodel), I18n.t(:auto_reg_date), I18n.t(:auto_km), I18n.t(:serve_datetime) ]
          @orders.where(:state.gte => 5, :state.lte => 7, :auto_submodel.ne => nil).each do |o|
            if o.registration_date
              d = I18n.l(o.registration_date)
            else
              d = ''
            end
            csv << [o.seq, o.name, o.auto_owner_name, o.address, o.car_location + o.car_num, o.auto_submodel.full_name, d, o.auto_km, I18n.l(o.serve_datetime) ]
          end
        end
        headers['Last-Modified'] = Time.now.httpdate
        send_data csv, :filename => 'orders_' + I18n.l(DateTime.now) + '.csv'
      }
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
      format.json
    end
  end

  def print
    @order = Order.find(params[:id])
    render layout: false
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
    @order.part_deliver_state = 0
    @order.serve_datetime = DateTime.now.since(1.days)
    @order.discounts = nil
    @order.friend_phone_num = ''
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
    if params[:inquire]
      @order.state = 9
      notice = :inquiry_created
    else
      @order.state = 2
      notice = :order_created
    end
    respond_to do |format|
      if @order.save
        format.html { redirect_to orders_url, notice: I18n.t(notice, seq: @order.seq) }
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
    params[:edit_all] = true if request.format.json?
    
    params[:order][:car_num].upcase! if params[:order][:car_num]
    @order = Order.find(params[:id])
    if params[:verify_failed]
      params[:order][:state] = 1
      notice = I18n.t(:order_verify_failed, seq: @order.seq)
    elsif params[:edit_all] || params[:add_comment]
      notice = I18n.t(:order_saved_notify, seq: @order.seq)
    elsif params[:cancel]
      params[:order][:state] = 8
      notify_order_state_change @order, params[:order][:state]
      if @order.balance_pay > 0
        params[:order][:balance_pay] = 0
        c = Client.find_or_create_by phone_num: @order.phone_num
        if c
          c.update_attributes balance: c.balance + @order.balance_pay
        end
      end
      notice = I18n.t(:order_cancelled, seq: @order.seq)
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
        if params[:order][:part_deliver_state] == '1'
          params[:order][:state] = 3
          notice = I18n.t(:order_delivered_notify, seq: @order.seq)
        else
          params[:order][:state] = 4
          notify_order_state_change @order, params[:order][:state]
          notice = I18n.t(:order_scheduled_notify, seq: @order.seq)
        end
      when 4
        if params[:order][:part_deliver_state] == '1'
          params[:order][:state] = 4
          notice = I18n.t(:order_delivered_notify, seq: @order.seq)
        else
          if @order.part_deliver_state == 0
            return render json: {error: t(:order_create_failed)}, status: :bad_request
          end
          params[:order][:state] = 5
          notify_order_state_change @order, params[:order][:state]
          notice = I18n.t(:order_served_notify, seq: @order.seq)
        end
      when 5
        if params[:order][:part_deliver_state] == '2'
          params[:order][:state] = 5
          notice = I18n.t(:order_part_backed_notify, seq: @order.seq)
        else
          params[:order][:state] = 6
          notice = I18n.t(:order_handovered_notify, seq: @order.seq)
        end
      when 6
        params[:order][:state] = 7
        notice = I18n.t(:order_revisited_notify, seq: @order.seq)
      when 8
        params[:order][:state] = 8
        if params[:order][:part_deliver_state] == '2'
          notice = I18n.t(:order_part_backed_notify, seq: @order.seq)
        end
      when 10
        params[:order][:state] = 5
        notice = I18n.t(:order_served_notify, seq: @order.seq)
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
        format.json { render json: {result: 'ok'} }
      else
        format.html { render action: "edit" }
        format.json { render json: { result: @order.errors[0] } }
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

    p = @order.calc_price
    if p > 0.0 && @order.phone_num.present?
      c = Client.find_by phone_num: @order.phone_num
      if c && c.balance > 0.0
        #使用账户余额
        used = [c.balance, p].min
        @order.balance_pay = used
      end
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

  def auto_maintain_query
    auto_maintain
    render 'auto_maintain'
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
          csv << ['ID', I18n.t(:owner_auto_brand), I18n.t(:owner_auto_brand)+'ID', I18n.t(:series), I18n.t(:series)+'ID', I18n.t(:auto_submodel), I18n.t(:engine_model), I18n.t(:total_price_with_st)]
          @asms.each do |asm|
            params[:asm_id] = asm.id.to_s
            auto_maintain
            csv << [@order.auto_submodel.id, @order.auto_submodel.auto_model.auto_brand.name, @order.auto_submodel.auto_model.auto_brand.id.to_s, @order.auto_submodel.auto_model.name, @order.auto_submodel.auto_model.id.to_s, @order.auto_submodel.full_name, @order.auto_submodel.engine_model, @order.calc_price ]
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
    asm = AutoSubmodel.find(params[:asm_id])
    return render json: t(:auto_submodel_required), status: :bad_request if asm.nil?
    return render json: {result: t(:info_needed)}, status: :bad_request if params[:info].nil?
    return render json: {result: t(:address_needed)}, status: :bad_request if params[:info][:address].nil? || params[:info][:address].empty?
    return render json: {result: t(:name_needed)}, status: :bad_request if params[:info][:name].nil? || params[:info][:name].empty?
    return render json: {result: t(:phone_num_needed)}, status: :bad_request if params[:info][:phone_num].nil? || params[:info][:phone_num].empty?
    return render json: {result: t(:car_location_needed)}, status: :bad_request if params[:info][:car_location].nil? || params[:info][:car_location].empty?
    return render json: {result: t(:car_num_needed)}, status: :bad_request if params[:info][:car_num].nil? || params[:info][:car_num].empty?
    return render json: {result: t(:city_needed)}, status: :bad_request if params[:info][:city_id].nil? || params[:info][:city_id].empty?
    city = City.find(params[:info][:city_id])
    return render json: t(:city_invalid), status: :bad_request if city.nil?
    
    _create_auto_maintain_order

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
    return render json: {result: t(:city_needed)}, status: :bad_request if params[:info][:city_id].nil? || params[:info][:city_id].empty?
    city = City.find(params[:info][:city_id])
    return render json: t(:city_invalid), status: :bad_request if city.nil?
    
    _create_auto_maintain_order
    if @order.parts.empty?
      @order.buymyself = true
    end
    @order.update_attributes params[:info]
    @order.car_num.upcase!
    @order.save!
    render json: {result: 'succeeded', seq: @order.seq }
  end

  def create_auto_maintain_order3
    return render json: {result: t(:info_needed)}, status: :bad_request if params[:info].nil?
    return render json: {result: t(:address_needed)}, status: :bad_request if params[:info][:address].nil? || params[:info][:address].empty?
    return render json: {result: t(:name_needed)}, status: :bad_request if params[:info][:name].nil? || params[:info][:name].empty?
    return render json: {result: t(:phone_num_needed)}, status: :bad_request if params[:info][:phone_num].nil? || params[:info][:phone_num].empty?
    return render json: {result: t(:car_location_needed)}, status: :bad_request if params[:info][:car_location].nil? || params[:info][:car_location].empty?
    return render json: {result: t(:car_num_needed)}, status: :bad_request if params[:info][:car_num].nil? || params[:info][:car_num].empty?
    _create_auto_maintain_order
    return render json: {result: t(:parts_needed)}, status: :bad_request if @order.parts.empty?
    @order.city = City.find_by name: I18n.t(:beijing)
    @order.user_type = UserType.find_or_create_by name: I18n.t(:baichebao)
    @order.update_attributes params[:info]
    @order.car_num.upcase!
    @order.save!
    render json: {result: 'succeeded', seq: @order.seq }
  end

  def create_auto_maintain_order4
    return render json: {result: t(:info_needed)}, status: :bad_request if params[:info].nil?
    return render json: {result: t(:address_needed)}, status: :bad_request if params[:info][:address].nil? || params[:info][:address].empty?
    return render json: {result: t(:name_needed)}, status: :bad_request if params[:info][:name].nil? || params[:info][:name].empty?
    return render json: {result: t(:phone_num_needed)}, status: :bad_request if params[:info][:phone_num].nil? || params[:info][:phone_num].empty?
    return render json: {result: t(:car_location_needed)}, status: :bad_request if params[:info][:car_location].nil? || params[:info][:car_location].empty?
    return render json: {result: t(:car_num_needed)}, status: :bad_request if params[:info][:car_num].nil? || params[:info][:car_num].empty?
    _create_auto_maintain_order
    @order.city = City.find_by name: I18n.t(:beijing)
    @order.user_type = UserType.find_or_create_by name: I18n.t(:weiche)
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
  
  def order_prompt
    @orders = Order.all
    if params[:state].present?
      @orders = @orders.where(state: params[:state])
    end

    if params[:states].present?
      @orders = @orders.any_of(params[:states].collect { |x| {state: x.to_i} } )
    end

    if params[:part_deliver_state].present?
      @orders = @orders.where(part_deliver_state: params[:part_deliver_state])
    end
    
    respond_to do |format|
      format.json
      format.js
    end
  end
  
  def order_seq_check
    @order = Order.where(seq: params[:seq]).first

    respond_to do |format|
      format.json 
      format.js
    end
  end
  
  def tag_stats
    result = {}
    orders = AutoSubmodel.find(params[:auto_submodel_id]).orders
    Order::EVALUATION_TAG.each do |tag|
      result[tag] = orders.select {|order| order.evaluation_tags.include? tag}.count
    end
    respond_to do |format|
      format.json { render json: result}
    end
  end
  
  def evaluation_list
    auto_submodel_id = params[:auto_submodel_id]
    @orders = AutoSubmodel.find(auto_submodel_id).orders.where(:evaluation_time.ne => nil).desc(:evaluation_time).page(params[:page]).per(params[:per])
  end

  def tomorrow_orders
    @d = Date.parse(params[:date]) || Date.tomorrow
    @unassigned_orders = Order.where state: 2,  :serve_datetime.lte => @d.end_of_day, :serve_datetime.gte => @d.beginning_of_day
    @unscheduled_orders = Order.where state: 3, :serve_datetime.lte => @d.end_of_day, :serve_datetime.gte => @d.beginning_of_day
    @scheduled_orders = Order.where state: 4, :serve_datetime.lte => @d.end_of_day, :serve_datetime.gte => @d.beginning_of_day
    @order_count = @unassigned_orders.count + @unscheduled_orders.count + @scheduled_orders.count
    @engineers = User.asc(:name).select { |u| u.roles.include? User::ROLE_STRINGS.index('engineer').to_s }
    render layout: false
  end

private
  def _create_auto_maintain_order
    @order = Order.new
    if params[:asm_id].present?
      asm = AutoSubmodel.find(params[:asm_id])
      @order.auto_submodel = asm
    end
    cabin_filter_only = true
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
          if ![I18n.t(:cabin_filter), I18n.t(:pm25_filter)].include? p.part_type.name
            cabin_filter_only = false
          end
          @order.parts << p
          @order.part_counts[p.id.to_s] = asm.cals_part_count(p)
        end
      end
    end

    if @order.parts.exists? && cabin_filter_only
      cabin_filter_service = ServiceType.find '527781867ef560ccbc000007'
      return render json: t(:cabin_filter_service_type_not_found), status: :bad_request if cabin_filter_service.nil?
      @order.service_types << cabin_filter_service
    else
      maintain_service = ServiceType.find '527781377ef560ccbc000003'
      return render json: t(:auto_maintain_service_type_not_found), status: :bad_request if maintain_service.nil?
      @order.service_types << maintain_service
    end

    check_discount
  end

  def check_discount
    if params[:discount].present?
      discount = Discount.find_by token: params[:discount]
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

  def notify_order_state_change( o, state)
    ut = UserType.find_by name: I18n.t(:weiche)
    if ut && o.user_type == ut
      require 'net/http'
      s = Digest::MD5.hexdigest "channel=kalading&order_id=#{o.seq}&order_status=#{state}&withkey=oMi5guNg6Py4l8YOKeL_NEq2uLI8"
      r = Net::HTTP.post_form URI.parse('http://wx.wcar.net.cn/script/weiche_order_feedback.php'),
        { channel: 'kalading', order_id: o.seq, order_status: state, sign: s }
      logger.info "Notify weiche order: #{r.body}"
    end
  end
end
