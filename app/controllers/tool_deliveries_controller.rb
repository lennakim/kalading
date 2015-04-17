class ToolDeliveriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource except: [:prepare_for_receiving]
  before_filter :find_tool_delivery, only: [:prepare_for_receiving]

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

  def show
  end

  def prepare_for_receiving
    authorize! :receive, @tool_delivery
  end

  def receive
    if @tool_delivery.receive(params[:tool_delivery][:tool_delivery_items_attributes].values, current_user)
      redirect_to tool_deliveries_path
    else
      render action: 'prepare_for_receiving'
    end
  end

  private

    def find_tool_delivery
      @tool_delivery = ToolDelivery.find(params[:id])
    end
end
