class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /users
  # GET /users.json
  def index
    @users = User.all.asc(:name_pinyin)
    if !params[:name].blank?
      @users = @users.where(name: /.*#{params[:name]}.*/i)
    end
    if !params[:phone_num].blank?
      @users = @users.where(phone_num: params[:phone_num])
    end
    if !params[:belong].blank?
      @users = @users.where(storehouse: Storehouse.find(params[:belong]))
    end
    if !params[:city].blank?
      @users = @users.where(city: City.find(params[:city]))
    end

    if !params[:state].blank?
      @users = @users.where(state: params[:state])
    end

    if !params[:role].blank?
      @users = @users.select { |u| u.roles.include? params[:role] }
    end

    respond_to do |format|
      format.js
      format.html { @users = Kaminari.paginate_array(@users).page params[:page] }
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    # rails 3 bug
    params[:user][:roles].reject!(&:blank?)
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_url, notice: I18n.t(:new_user_notify, name: @user.name, role: @user.role_str ) }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])
    params[:user][:roles].reject!(&:blank?)
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to users_url, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def update_realtime_info
    if params[:location]
      current_user.location = params[:location]
    end
    if params[:battery_level]
      current_user.battery_level = params[:battery_level]
    end
    current_user.update_datetime = DateTime.now
    current_user.save!
    render json: {result: 'ok'}
  end

  def get_realtime_info
    @engineers = User.where(roles: ['5'])
    respond_to do |format|
      format.js
    end
  end
end
