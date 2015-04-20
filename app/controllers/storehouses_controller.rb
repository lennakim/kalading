class StorehousesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_default_operator
  load_and_authorize_resource :except => [:import]

  # GET /storehouses
  # GET /storehouses.json
  def index
    if current_user && current_user.roles.include?('3')
      @storehouses = Storehouse.where(city: current_user.city)
    else
      @storehouses = Storehouse.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @storehouses }
    end
  end

  # GET /storehouses/1
  # GET /storehouses/1.json
  def show
    @storehouse = Storehouse.find(params[:id])
    pbs = @storehouse.partbatches.desc(:created_at)
    if params[:part_number].present?
      pbs = pbs.where(part: Part.find_by(number: params[:part_number]))
    end
    @partbatches = pbs.page(params[:page])

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
    @order = Order.find params[:order] if params[:order].present?
  end

  def inout
    @storehouse = Storehouse.find(params[:id])
    @part = Part.find params[:part]
    @partbatches = @storehouse.partbatches.where(part: @part).asc(:created_at)
    @quantity = params[:quantity].to_i
    @order = self.current_order = Order.find params[:order]
    @order.part_delivered_counts[@part.id.to_s] ||= 0
    if params[:back]
      if @quantity <=0 || @quantity > @order.part_delivered_counts[@part.id.to_s].to_i
        @error = I18n.t :quantity_error, min: 1, max: @order.part_delivered_counts[@part.id.to_s].to_i
      end
    else
      if @quantity <= 0 || @quantity > @order.part_counts[@part.id.to_s].to_i - @order.part_delivered_counts[@part.id.to_s].to_i
        @error = I18n.t :quantity_error, min: 1, max: @order.part_counts[@part.id.to_s].to_i - @order.part_delivered_counts[@part.id.to_s].to_i
      end
    end
    return if @error

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
      @order.part_delivered_counts[@part.id.to_s] -= @quantity
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
      @order.part_delivered_counts[@part.id.to_s] += @quantity
    end
    @order.save!
    #@history_trackers = Kaminari.paginate_array(HistoryTracker.where(scope: 'partbatch').desc(:created_at)).page(0).per(5)
  end

  # POST /storehouses
  # POST /storehouses.json
  def create
    @storehouse = Storehouse.new(params[:storehouse])

    respond_to do |format|
      if @storehouse.save
        format.html { redirect_to storehouses_url, notice: 'Storehouse was successfully created.' }
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
        format.html { redirect_to storehouses_url, notice: 'Storehouse was successfully updated.' }
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

    part = Part.find_or_create_by number: params[I18n.t(:part_number)], part_brand_id: part_brand.id, part_type_id: part_type.id
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
  
  def statistics
    respond_to do |format|
      format.csv {
        csv_data = CSV.generate do |csv|
          # CSV Header
          a = [I18n.t(:part_brand), I18n.t(:part_number), I18n.t(:part_type)]
          a += [I18n.t(:in_quantity), I18n.t(:remained_quantity)]
          storehouse_ids_of_cities = []
          City.where(opened: true).asc(:created_at).each do |city|
            a << "#{city.name + I18n.t(:remained_quantity)}"
            storehouse_ids_of_cities << Hash[city.storehouses.map {|sh| [sh.id.to_s, 1]}]
          end
          d1 = Date.today.ago(1.year).beginning_of_month
          first_ht_dt = HistoryTracker.asc(:created_at).first.created_at
          d1 = first_ht_dt.beginning_of_month if d1 < first_ht_dt
          d2 = Date.today.ago(1.month).end_of_month
          monthly_part_delivered = []
          d = d1
          while d < d2
            a << I18n.t(:month_delivered, y: d.year, m: d.month)
            # 统计每个月每个partbatch的出库量
            monthly_part_delivered << HistoryTracker.pb_to_part_delivered(d, 1.month.since(d))
            d = 1.month.since(d)
          end
          a += [I18n.t(:total_delivered), I18n.t(:needed_this_week), I18n.t(:store_warning), I18n.t(:max_delivered), I18n.t(:remark)]
          csv << a
          Partbatch.stats do |data|
            p = Part.find data['_id']
            a = [p.part_brand.name, p.number, p.part_type.name]
            a += [data['value']['quantity'], data['value']['remained_quantity']]
            a += storehouse_ids_of_cities.map do |sh_ids|
              data['value']['storehouse_remained'].inject(0) { |sum, (k,v)| sum + (sh_ids.has_key?(k) ? v : 0) }
            end
            monthly_part_delivered.each do |mpd|
              a << data['value']['pb_ids'].inject(0) { |sum, pb_id| sum + mpd[pb_id].to_i }
            end
            a << data['value']['quantity'] - data['value']['remained_quantity']
            last_month_delivered = a[-2].to_f
            a << (last_month_delivered * 1.5 + 3 - data['value']['remained_quantity']).to_i
            a << (last_month_delivered + 3).to_i
            a << (last_month_delivered * 1.5 + 3).to_i
            a << p.remark
            csv << a
          end
        end
        headers['Last-Modified'] = Time.now.httpdate
        send_data csv_data, :filename => I18n.l(DateTime.now) + '.csv'
      }
    end
  end

  def part_transfer
    @storehouse = Storehouse.find(params[:id])
    @part = PartBrand.desc(:name).first.parts.first
    @q = @storehouse.partbatches.where(part: @part).sum(:remained_quantity)
    respond_to do |format|
      format.html
      format.js # show.js.erb
    end
  end

  def part_transfer_to
    @storehouse = Storehouse.find params[:id]
    @target_storehouse = Storehouse.find params[:target_storehouse][:id]
    @part = Part.find params[:part][:id]
    @partbatches = @storehouse.partbatches.where(part: @part).asc(:created_at)
    @quantity = params[:quantity].to_i
    need_q = @quantity
    # 调货不产生出入库记录
    Partbatch.disable_tracking do
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
    
    @pt = PartTransfer.create!(source_sh: @storehouse, target_sh: @target_storehouse, quantity: @quantity, part: @part)
    respond_to do |format|
      format.html
      format.js # show.js.erb
    end
  end
  
  def print_dispatch_card
    @storehouse = Storehouse.find(params[:id])
    @start_time = (params[:start_time].present? && DateTime.parse(params[:start_time])) || (DateTime.now.hour <= 12 ? Date.today.beginning_of_day : Date.tomorrow.beginning_of_day)
    @end_time = (params[:end_time].present? && DateTime.parse(params[:end_time])) || Date.tomorrow.end_of_day
    render layout: false
  end
  
  def print_orders_card
    @storehouse = Storehouse.find(params[:id])
    @start_time = (params[:start_time].present? && DateTime.parse(params[:start_time])) || Date.tomorrow.beginning_of_day
    @end_time = (params[:end_time].present? && DateTime.parse(params[:end_time])) || Date.tomorrow.end_of_day
    render layout: false
  end

  def part_yingyusunhao
    @storehouse = Storehouse.find(params[:id])
    @part = PartBrand.desc(:name).first.parts.first
    @remained_quantity = @storehouse.partbatches.where(part: @part).sum(:remained_quantity)
    respond_to do |format|
      format.html
      format.js # show.js.erb
    end
  end

  def do_part_yingyusunhao
    @storehouse = Storehouse.find params[:id]
    @part = Part.find params[:part][:id]
    @quantity = params[:quantity].to_i
    if params[:sunhao].to_i == 1
      need_q = @quantity
      @partbatches = @storehouse.partbatches.where(part: @part).asc(:created_at)
      @partbatches.each do |pb|
        c = [need_q, pb.remained_quantity].min
        pb.update_attribute :remained_quantity, pb.remained_quantity - c
        pb.part.auto_submodels.each do |asm|
          asm.on_part_inout pb.part, -c
        end
        need_q -= c
        break if need_q <= 0
      end
    else
      supplier = Supplier.find_or_create_by name: I18n.t(:fake_supplier_for_yingyu), type: 2
      @storehouse.partbatches.create! part_id: @part.id,
        supplier_id: supplier.id,
        price: @part.partbatches.desc(:create_at).first.try(:price) || @part.ref_price,
        quantity: @quantity,
        remained_quantity: @quantity,
        user_id: current_user.id
    end
    respond_to do |format|
      format.html
      format.js # show.js.erb
    end
  end
  
  def city_part_requirements
    @city = City.find params[:city]
    storehouse_ids = @city.storehouses.map(&:id)
    @start_date = Date.parse params[:start_date]
    @end_date = Date.parse params[:end_date]
    @parts = {}
    Order.where(:serve_datetime.gte => DateTime.now, :serve_datetime.lte => @end_date.beginning_of_day, city: @city).each do |o|
      o.parts.each do |p|
        @parts[p] ||= {required: 0, remained: p.partbatches.where(:storehouse_id.in => storehouse_ids).sum(&:remained_quantity) }
        @parts[p][:required] += o.part_counts[p.id.to_s].to_i
      end
    end
    @parts = @parts.sort_by {|k, v| k.part_brand}
    if params[:export].present?
      csv_data = CSV.generate do |csv|
        a = [I18n.t(:brand), I18n.t(:manuf_number), I18n.t(:part_type), I18n.t(:needed)]
        csv << a
        # CSV lines
        @parts.each do |p, i|
          next if i[:required] <= i[:remained]
          a = [p.part_brand.name, p.number, p.part_type.name, i[:required] - i[:remained]]
          csv << a
        end
      end
      headers['Last-Modified'] = Time.now.httpdate
      send_data csv_data, :filename => @city.name + I18n.t(:needed)+ I18n.l(DateTime.now.to_date) + '.csv'
    end
  end
end
