class ServiceVehiclesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @service_vehicles = ServiceVehicle.page(params[:page]).per(20)
  end

  def new
    @service_vehicle = ServiceVehicle.new
  end

  def create
    @service_vehicle = ServiceVehicle.new(params[:service_vehicle])
    if @service_vehicle.save
      redirect_to service_vehicles_path
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @service_vehicle.update_attributes(params[:service_vehicle])
      redirect_to service_vehicles_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @service_vehicle.destroy
    redirect_to service_vehicles_path
  end
end
