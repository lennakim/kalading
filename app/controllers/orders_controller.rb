class OrdersController < ApplicationController
  before_filter :check_for_mobile, :only => [:index, :order_begin, :choose_service]
  @except_actions = [
    :index, :show, :update, :create, :auto_maintain, :auto_maintain_price, :create_auto_maintain_order, :latest_orders, :create_auto_maintain_order2, :create_auto_verify_order, :create_auto_test_order, :auto_test_price, :auto_test_order, :auto_verify_price, :auto_verify_order, :tag_stats, :evaluation_list, :create_auto_special_order
  ]
  before_filter :authenticate_user!, :except => @except_actions
  before_filter :set_default_operator
  load_and_authorize_resource :except => @except_actions + [:auto_maintain_query, :create_auto_maintain_order3, :create_auto_maintain_order4, :create_auto_maintain_order5]

  # GET /orders
  # GET /orders.json
  def index
    if current_user
      if current_user.roles.empty?
        logger.info "Current user name: #{current_user.name}"
        authorize! :read, Order
      elsif current_user.roles.include? '5'
        @orders = Order.where(:engineer => current_user)
      elsif current_user.roles.include? '3'
        @orders = Order.where(:city => current_user.city)
        params[:city] = current_user.city.id
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
    
    if !params[:reciept_type].blank?
      @orders = @orders.where reciept_type: params[:reciept_type]
    end
    
    if !params[:reciept_state].blank?
      @orders = @orders.where reciept_state: params[:reciept_state]
    end

    if params[:cancel_type].present?
      @orders = @orders.where cancel_type: params[:cancel_type]
    end

    if !params[:storehouse].blank?
      @orders = @orders.where(storehouse: Storehouse.find(params[:storehouse]))
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
    if current_user && current_user.roles.include?('6')
      @order.dispatcher = current_user
    end
    if params[:customerNumber].present?
      @order.incoming_call_num = params[:customerNumber]
      @order.phone_num = params[:customerNumber]
    end
    if params[:customerAreaCode].present?
      @order.city = City.find_by area_code: params[:customerAreaCode]
    else
      @order.city = City.find_by name: I18n.t(:beijing)
    end
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
    if d && d.expire_date >= Date.today && d.orders.count < d.times && (d.service_types.blank? || d.service_type_ids.sort == @order.service_type_ids.sort)
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
    elsif params[:edit_all] || params[:add_comment] || params[:invoice]
      notice = I18n.t(:order_saved_notify, seq: @order.seq)
    elsif params[:cancel]
      params[:order][:state] = 10
      if @order.balance_pay > 0
        params[:order][:balance_pay] = 0
        c = Client.find_or_create_by phone_num: @order.phone_num
        if c
          c.update_attributes balance: c.balance + @order.balance_pay
        end
      end
      notice = I18n.t(:order_cancel_pending, seq: @order.seq)
    elsif params[:cancel_confirm]
      params[:order][:state] = 8
      notify_order_state_change @order, params[:order][:state]
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
        params[:order][:state] = 10
        if params[:order][:part_deliver_state] == '2'
          notice = I18n.t(:order_part_backed_notify, seq: @order.seq)
        else
          notice = I18n.t(:order_served_notify, seq: @order.seq)
        end
      else
        notice = I18n.t(:order_saved_notify, seq: @order.seq)
      end
    end

    respond_to do |format|
      if @order.update_attributes(params[:order])
        _auto_send_sms_notify @order, params[:order][:state]
        if params[:order][:discount_num]
          @order.discounts = nil
          d = Discount.find_by token: params[:order][:discount_num]
          if d && d.expire_date >= Date.today && d.orders.count < d.times && (d.service_types.blank? || d.service_type_ids.sort == @order.service_type_ids.sort)
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
    asm.parts_by_type_ignore_quantity.each do |t, parts|
      if t.name == I18n.t(:engine_oil)
        parts.group_by(&:spec)[parts.first.spec].each do |p|
          @order.parts << p
          @order.part_counts[p.id.to_s] = asm.cals_part_count(p)
        end
      elsif t.name == I18n.t(:cabin_filter)
        part = parts.find {|p| p.part_brand_id.to_s == '539d4d019a94e4de84000567'} || parts.first
        @order.parts << part
        @order.part_counts[part.id.to_s] = asm.cals_part_count(part)
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
  
  def create_auto_maintain_order5
    return render json: {result: t(:info_needed)}, status: :bad_request if params[:info].nil?
    return render json: {result: t(:address_needed)}, status: :bad_request if params[:info][:address].nil? || params[:info][:address].empty?
    return render json: {result: t(:name_needed)}, status: :bad_request if params[:info][:name].nil? || params[:info][:name].empty?
    return render json: {result: t(:phone_num_needed)}, status: :bad_request if params[:info][:phone_num].nil? || params[:info][:phone_num].empty?

    _create_auto_maintain_order
    @order.city = City.find_by name: I18n.t(:beijing)
    if !params[:free].blank?
      @order.user_type = UserType.find_or_create_by name: I18n.t(:renbaodianxiao)
    else
      @order.user_type = UserType.find_or_create_by name: I18n.t(:renbao)
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
    check_discount(params[:info][:discount]) if params[:info][:discount].present?
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
    check_discount(params[:info][:discount]) if params[:info][:discount].present?
    @order.update_attributes params[:info]
    @order.car_num.upcase!
    @order.save!
    render json: {result: 'succeeded', seq: @order.seq }
  end
  
  # only phone_num and car_num, default city is beijing
  def create_auto_special_order
    return render json: {result: t(:info_needed)}, status: :bad_request if params[:info].nil?
    return render json: {result: t(:phone_num_needed)}, status: :bad_request if params[:info][:phone_num].nil? || params[:info][:phone_num].empty?
    return render json: {result: t(:car_num_needed)}, status: :bad_request if params[:info][:car_num].nil? || params[:info][:car_num].empty?
    @order = Order.new
    @order.service_types << ServiceType.find('527781867ef560ccbc000007')
    if (8..19).include? DateTime.now.hour
      dispatcher_states = [0]
    else
      dispatcher_states = [0, 1]
    end
    @order.dispatcher = User.where(:roles => [User::ROLE_STRINGS.index('dispatcher').to_s]).any_in(state: dispatcher_states).sample
    @order.city = City.find_by name: I18n.t(:beijing)
    check_discount(params[:info][:discount]) if params[:info][:discount].present?
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
    check_discount(params[:info][:discount]) if params[:info].present? && params[:info][:discount].present?
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
    check_discount(params[:info][:discount]) if params[:info].present? && params[:info][:discount].present?
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
    
    if current_user.roles == [User::ROLE_STRINGS.index('dispatcher').to_s]
      @orders = @orders.where dispatcher: current_user
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
    #orders = AutoSubmodel.find(params[:auto_submodel_id]).orders
    #Order::EVALUATION_TAG.each do |tag|
    #  result[tag] = orders.select {|order| order.evaluation_tags.include? tag}.count
    #end
    respond_to do |format|
      format.json { render json: result}
    end
  end
  
  def evaluation_list
    @orders = Order.any_in(state: [5,6,7]).where(:evaluation_tags.ne => []).desc(:evaluation_time).page(params[:page]).per(params[:per])
  end

  def daily_orders
    @d = Date.parse(params[:date]) if params[:date]
    @d ||= Date.tomorrow
    @unassigned_orders = Order.where(state: 2,  :serve_datetime.lte => @d.end_of_day, :serve_datetime.gte => @d.beginning_of_day).asc(:address)
    @city_unassigned_orders = @unassigned_orders.group_by(&:city)
    City.each {|c| @city_unassigned_orders[c] ||= []}
    @engineer_order_hash = Order.any_of({state: 3}, {state: 4}).where(:serve_datetime.lte => @d.end_of_day, :serve_datetime.gte => @d.beginning_of_day).asc(:serve_datetime).group_by(&:engineer)
    @storehouse_engineers = User.where(state: 0, roles: ['5']).asc(:storehouse).group_by(&:storehouse)
    @dianbu_postions = {}
    Storehouse.asc(:city).each do |sh|
      @dianbu_postions[sh] = get_latitude_longitude(sh.city.name, sh.address)
    end
    render layout: false
  end
  
  def send_sms_notify
    session[:return_to] ||= request.referer
    @order = Order.find(params[:id])
    if @order.state == 0 || @order.state == 1
      reason = I18n.t(:sms_reason_unverified)
    end
    if @order.state == 10
      if @order.cancel_type == 2
        reason == I18n.t(:sms_reason_client_reschedule)
      end
      if @order.cancel_type == 3
        reason == I18n.t(:sms_reason_part_error)
      end
    end
    send_sms @order.phone_num, '647223', "#reason#=#{reason}"
    @order.comments << Comment.new(text: I18n.t(:sms_comment, dispatcher: @order.dispatcher.name, time: Time.now.strftime('%m-%d %H:%M')))
    redirect_to session.delete(:return_to), notice: I18n.t(:send_sms_successful, seq: @order.seq)
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
    
    if params[:info].present? && params[:info][:discount].present?
      check_discount(params[:info][:discount])
    elsif params[:discount].present?
      check_discount(params[:discount])
    end
    #8:00-20:00 online dispatchers are available, 20:00-tomorrow 8:00 online and offline dispatchers are available
    if (8..19).include? DateTime.now.hour
      dispatcher_states = [0]
    else
      dispatcher_states = [0, 1]
    end
    @order.dispatcher = User.where(:roles => [User::ROLE_STRINGS.index('dispatcher').to_s]).any_in(state: dispatcher_states).sample
  end

  def check_discount discount
    discount = Discount.find_by token: discount
    if discount
      if discount.expire_date < Date.today
        @discount_error = I18n.t(:discount_expired, s: (I18n.l discount.expire_date ) )
      elsif discount.orders.count >= discount.times
        @discount_error = I18n.t(:discount_no_capacity)
      elsif discount.service_types.present? && discount.service_type_ids.sort != @order.service_type_ids.sort
        @discount_error = I18n.t(:discount_service_types_error, s: discount.service_types.map{|s| s.name}.join(',') )
      else
        @order.discounts << discount
      end
    else
      @discount_error = I18n.t(:discount_not_exist)
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

  def _auto_send_sms_notify(o, state)
    if state == 2
      servedate = o.serve_datetime.strftime "%m#{I18n.t(:month)}%d#{I18n.t(:day)}"
      url = CGI.escape('http://kalading.com')
      send_sms o.phone_num, '647221', "#autoname#=#{o.auto_submodel.full_name}&#servicetypes#=#{o.service_types.first.name}&#order#=#{o.seq}&#servedate#=#{servedate}&#url#=#{url}"
    end
    if state == 3
      send_sms o.phone_num, '647217', "#order#=#{o.seq}&#engineer#=#{o.engineer.name}&#phone#=#{o.engineer.phone_num}"
    end
  end
end
