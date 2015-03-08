class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  # GET /notifications
  # GET /notifications.json
  def index
    @notifications = Notification.all

    respond_to do |format|
      format.html { @notifications = @notifications.desc(:seq).page(params[:page]).per(15)}
      format.json { render json: @notifications }
    end
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
    @notification = Notification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @notification }
    end
  end

  # GET /notifications/new
  # GET /notifications/new.json
  def new
    @notification = Notification.new

    respond_to do |format|
      format.html
      format.json { render json: @notification }
    end
  end

  # GET /notifications/1/edit
  def edit
    @notification = Notification.find(params[:id])
  end

  # POST /notifications
  # POST /notifications.json
  def create
    @notification = Notification.new(params[:notification])
    if params[:send]
      notice = :notification_sent_notify
      @notification.push
    else
      notice = :notification_created_notify
    end
    respond_to do |format|
      if @notification.save
        format.html { redirect_to notifications_url, notice: I18n.t(notice, seq: @notification.seq) }
        format.json { render json: @notification, status: :created, location: @notification }
      else
        format.html { render action: "new" }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /notifications/1
  # PUT /notifications/1.json
  def update
    @notification = Notification.find(params[:id])
    if params[:send]
      notice = :notification_sent_notify
      @notification.push
    else
      notice = :notification_created_notify
    end
    respond_to do |format|
      if @notification.update_attributes(params[:notification])
        format.html { redirect_to notifications_url, notice: I18n.t(notice, seq: @notification.seq) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy

    respond_to do |format|
      format.html { redirect_to notifications_url }
      format.json { head :no_content }
    end
  end
end
