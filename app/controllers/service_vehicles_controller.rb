class ServiceVehiclesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource except: [:tool_assignments, :local]
  load_resource only: [:tool_assignments]

  def index
    criteria = ServiceVehicle

    if params[:number].present?
      params[:number].strip!
      criteria = criteria.where(:number => /#{params[:number]}/i)
    end

    if params[:city_id].present?
      criteria = criteria.where(city_id: params[:city_id])
    end

    @service_vehicles = criteria.page(params[:page]).per(20)
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
    if @service_vehicle.can_be_deleted?
      flash[:notice] = '删除成功'
      @service_vehicle.destroy
    else
      flash[:error] = "#{@service_vehicle.name} 不能被删除"
    end
    redirect_to service_vehicles_path
  end

  def tool_assignments
    if current_user.engineer?
      authorize! :read_and_discard, :local_vehicle_tool_assignments
    else
      authorize! :read, ToolAssignment
    end

    @assignee = @service_vehicle
    @suite_assignments = @assignee.tool_suite_assignments
    @part_assignments = @assignee.part_tool_assignments.current
    render 'tool_assignments/list_of_assignee'
  end

  def local
    authorize! :read_and_discard, :local_vehicle_tool_assignments
    @service_vehicles = ServiceVehicle.where(city_id: current_user.city_id).page(params[:page]).per(20)
  end
end
