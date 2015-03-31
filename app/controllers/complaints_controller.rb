class ComplaintsController < ApplicationController
  before_filter :authenticate_user!, :except => [:create]
  load_and_authorize_resource :except => [:create]

  # GET /Complaints
  # GET /Complaints.json
  def index
    @complaints = Complaint.all
    if !params[:state].blank?
      @complaints = @complaints.where(state: params[:state])
    end
    if !params[:customer_phone_num].blank?
      @complaints = @complaints.where(customer_phone_num: /.*#{params[:customer_phone_num]}.*/i)
    end
    if !params[:customer_name].blank?
      @complaints = @complaints.where(customer_name: /.*#{params[:customer_name]}.*/i)
    end
    if !params[:severity_level].blank?
      @complaints = @complaints.where(severity_level: params[:severity_level])
    end
    if !params[:complained].blank?
      @complaints = @complaints.where(complained: User.find(params[:complained]))
    end
    if !params[:handler].blank?
      @complaints = @complaints.where(handler: User.find(params[:handler]))
    end
    respond_to do |format|
      format.html { @complaints = @complaints.desc(:seq).page(params[:page]).per(15) }
      format.json { render json: @complaints }
    end
  end

  # GET /Complaints/1
  # GET /Complaints/1.json
  def show
    @complaint = Complaint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @complaint }
    end
  end

  # GET /Complaints/new
  # GET /Complaints/new.json
  def new
    @complaint = Complaint.new
    @complaint.creater = current_user if current_user
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @complaint }
    end
  end

  # GET /Complaints/1/edit
  def edit
    @complaint = Complaint.find(params[:id])
  end

  # POST /Complaints
  # POST /Complaints.json
  def create
    @complaint = Complaint.new(params[:complaint])

    order = Order.find_by(seq: params[:complaint][:order_seq])
    @complaint.order = order if order
    @complaint.creater = current_user

    respond_to do |format|
      if @complaint.save
        format.html { redirect_to complaints_url, notice: I18n.t(:complaint_created_notify, seq: @complaint.seq) }
        format.json { render json: @complaint, status: :created, location: @complaint }
      else
        format.html { render action: "new" }
        format.json { render json: @complaint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /Complaints/1
  # PUT /Complaints/1.json
  def update
    @complaint = Complaint.find(params[:id])
    
    if params[:handle]
      params[:complaint][:state] = 1
    end
    respond_to do |format|
      if @complaint.update_attributes(params[:complaint])
        order = Order.find_by(seq: params[:complaint][:order_seq])
        @complaint.order = order if order
        @complaint.handled_datetime = DateTime.now if params[:complaint][:state] == 1
        @complaint.save!
        format.html { redirect_to complaints_url, notice: I18n.t(:complaint_updated_notify, seq: @complaint.seq) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @complaint.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /Complaints/1
  # DELETE /Complaints/1.json
  def destroy
    @complaint = Complaint.find(params[:id])
    @complaint.destroy

    respond_to do |format|
      format.html { redirect_to Complaints_url }
      format.json { head :no_content }
    end
  end
  
  def send_sms_notify
    session[:return_to] ||= request.referer
    c = Complaint.find(params[:id])
    role_and_name = c.complained.role_str + ":" + c.complained.name
    phone_nums = [c.complained.phone_num]
    level = I18n.t(Complaint::SEVERITY_LEVEL_STRINGS[c.severity_level])
    if c.severity_level >= 1
      phone_nums << c.handler.phone_num
    end
    if c.severity_level >= 2
      #send message to jicheng jiajiping dongxiangchen
      phone_nums += User.any_in(id: ['5281b4837ef560db54000056','5281b4b97ef560db54000059','5281b4fd7ef560db5400005d']).map(&:phone_num)
    end

    phone_nums = phone_nums.join(',')
    send_sms phone_nums, '680925', "#complainted#=#{role_and_name}&#reason#=#{c.tag.name}&#order_seq#=#{c.order.seq if c.order}&#source#=#{c.source}&#level#=#{level}&#handler#=#{c.handler.name if c.handler}"
    c.comments << Comment.new(text: I18n.t(:complaint_sms_comment, handler: current_user.name, time: Time.now.strftime('%m-%d %H:%M')))
    redirect_to session.delete(:return_to), notice: I18n.t(:complaint_send_sms_successful, seq: c.seq)
  end
end
