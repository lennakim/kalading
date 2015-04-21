class PartTransfersController < InheritedResources::Base
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @part_transfers = PartTransfer.desc(:created_at)

    if current_user.storehouse_admin?
      @part_transfers = @part_transfers.where :target_sh_id.in => current_user.city.storehouses.map(&:id)
    end

    if params[:aasm_state].present?
      @part_transfers = @part_transfers.where(aasm_state: params[:aasm_state])
    end

    if params[:target_sh].present?
      @part_transfers = @part_transfers.where(target_sh: Storehouse.find(params[:target_sh]))
    end
    @part_transfers = @part_transfers.page params[:page]
    index!
  end
  
  def finish
    @part_transfer = PartTransfer.find params[:id]
    @part_transfer.finish!(:part_transfer_finished, current_user)
    respond_to do |format|
      format.js
      format.json
    end
  end
end

