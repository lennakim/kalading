class CitiesController < ApplicationController
  before_filter :authenticate_user!, :except => [ :index, :show ]
  load_and_authorize_resource :except => [ :index, :show, :capacity ]

  # GET /cities
  # GET /cities.json
  def index
    @cities = City.all

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
    d2 ||= Date.tomorrow.since(1.month).to_date
    if d1 < Date.today
      d1 = Date.today
    end
    if d2 > d1 + 31 || d2 < d1
      d2 = d1.since(1.month).to_date
    end
    h = {}
    (d1..d2).each do |d|
      h[d] = @city.order_capacity
    end
    Order.within_datetime_range(0, 4, d1.beginning_of_day, d2.end_of_day, @city).group_by {|o| o.serve_datetime.to_date}.each do |k, v|
      h[k] = [@city.order_capacity - v.count, 0].max
    end
    render json: h
  end
end
