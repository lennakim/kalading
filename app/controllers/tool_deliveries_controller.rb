class ToolDeliveriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource except: [:prepare_for_receiving, :new_suite_delivery, :deliver_suite]
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
    @tool_delivery.delivery_type = 'part'

    if @tool_delivery.save
      redirect_to tool_deliveries_path
    else
      render action: 'new'
    end
  end

  def new_suite_delivery
    authorize! :create, ToolDelivery

    @tool_delivery = ToolDelivery.new
  end

  def deliver_suite
    authorize! :create, ToolDelivery

    @tool_delivery = ToolDelivery.new(params[:tool_delivery])
    @tool_delivery.deliverer = current_user
    @tool_delivery.delivery_type = 'suite'

    if @tool_delivery.save
      redirect_to tool_deliveries_path
    else
      render action: 'new_suite_delivery'
    end
  end

  def show
  end

  def prepare_for_receiving
    authorize! :receive, @tool_delivery
  end

  def receive
    item_attrs = @tool_delivery.part? ? params[:tool_delivery][:tool_delivery_items_attributes].values :
                                        params[:tool_delivery][:tool_suite_deliveries_attributes].values
    if @tool_delivery.receive(item_attrs, current_user)
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
