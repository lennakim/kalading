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
    if params[:export].present?
      csv_data = CSV.generate do |csv|
        a = [I18n.t(:brand), I18n.t(:manuf_number), I18n.t(:part_type), I18n.t(:quantity), I18n.t(:to), I18n.t(:created_at), I18n.t(:state)]
        csv << a
        @part_transfers.each do |pt|
          csv << [pt.part.part_brand.name, pt.part.number, pt.part.part_type.name, pt.quantity, pt.target_sh.name, I18n.l(pt.created_at), I18n.t(pt.aasm_state)]
        end
      end
      headers['Last-Modified'] = Time.now.httpdate
      send_data csv_data, :filename => I18n.t(:part_transfer)+ I18n.l(DateTime.now.to_date) + '.csv'
      return
    end
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

