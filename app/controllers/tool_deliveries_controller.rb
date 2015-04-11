class ToolDeliveriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    criteria = ToolDelivery

    if current_user.storehouse_admin?
      criteria = criteria.where(to_city_id: current_user.city_id)
    end

    @tool_deliveries = criteria.page(params[:page]).per(20)
  end

  def new
  end

  def create
    @tool_delivery = ToolDelivery.new(params[:tool_delivery])
    @tool_delivery.deliverer = current_user

    if @tool_delivery.save
      redirect_to tool_deliveries_path
    else
      render action: 'new'
    end
  end

  def prepare_for_receiving
  end

  def receive
  end
end
