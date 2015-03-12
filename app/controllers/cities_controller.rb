class CitiesController < ApplicationController
  before_filter :authenticate_user!, :except => [ :index, :show, :capacity ]
  load_and_authorize_resource :except => [ :index, :show, :capacity ]

  # GET /cities
  # GET /cities.json
  def index
    if request.format.json?
      @cities = City.where(opened: true)
    else
      @cities = City.all
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cities }
    end
  end

  # GET /cities/1
  # GET /cities/1.json
  def show
    @city = City.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @city }
      format.js
    end
  end

  # GET /cities/new
  # GET /cities/new.json
  def new
    @city = City.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @city }
    end
  end

  # GET /cities/1/edit
  def edit
    @city = City.find(params[:id])
  end

  # POST /cities
  # POST /cities.json
  def create
    @city = City.new(params[:city])

    respond_to do |format|
      if @city.save
        format.html { redirect_to @city, notice: 'City was successfully created.' }
        format.json { render json: @city, status: :created, location: @city }
      else
        format.html { render action: "new" }
        format.json { render json: @city.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cities/1
  # PUT /cities/1.json
  def update
    @city = City.find(params[:id])

    respond_to do |format|
      if @city.update_attributes(params[:city])
        format.html { redirect_to @city, notice: 'City was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @city.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cities/1
  # DELETE /cities/1.json
  def destroy
    @city = City.find(params[:id])
    @city.destroy

    respond_to do |format|
      format.html { redirect_to cities_url }
      format.json { head :no_content }
    end
  end
  
  def capacity
    @city = City.find(params[:id])
    d1 = Date.parse params[:start_date] if params[:start_date]
    d1 ||= Date.tomorrow
    d2 = Date.parse params[:end_date] if params[:end_date]
    d2 ||= Date.today.since(2.weeks).to_date
    if d1 < Date.today
      d1 = Date.today
    end
    if d2 > d1 + 14 || d2 < d1
      d2 = d1.since(2.weeks).to_date
    end
    h = {}
    (d1..d2).each do |d|
      h[d] = [@city.order_capacity / 3 , @city.order_capacity / 3, @city.order_capacity / 3]
      if d == Date.tomorrow && DateTime.now.hour >= 17
        h[d] = [0,0,0]
      end
    end
    
    Order.within_datetime_range([0,2,3,4], d1.beginning_of_day, d2.end_of_day, @city).group_by {|o| o.serve_datetime.to_date}.each do |k, v|
      h[k] = [0,0,0] if v.count >= @city.order_capacity
      if h[k] != [0,0,0]
        v.group_by {|o| _time_stage(o.serve_datetime.hour)}.each do |s, y|
          h[k][s] = [@city.order_capacity / 3 - y.count, 0].max
        end
      end
    end
    render json: h
  end
private
  def _time_stage (hour)
    hour_hash = {0..11 => 0, 12..16 => 1, 17..23 => 1}
    stage = 0
    hour_hash.each do |k, v|
      stage = v if k.include? hour
    end
    stage
  end
end
