class PartTransfersController < InheritedResources::Base
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @part_transfers = PartTransfer.desc(:created_at)

    if params[:aasm_state].present?
      @part_transfers = @part_transfers.where(aasm_state: params[:aasm_state])
    end

    @part_transfers = @part_transfers.page params[:page]
    index!
  end
end

