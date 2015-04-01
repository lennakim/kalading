class EngineersController < ApplicationController
  inherit_resources

  def index
    @engineers = Engineer.all

    if params[:name].present?
      @engineers = @engineers.where(name: /.*#{params[:name]}.*/i)
    end

    if params[:phone_num].present?
      @engineers = @engineers.where(phone_num: params[:phone_num])
    end

    if params[:work_tag_number].present?
      @engineers = @engineers.where(work_tag_number: params[:work_tag_number])
    end

    if params[:city_id].present?
      @engineers = @engineers.where(city_id: params[:city_id])
    end

    if params[:city] && params[:city][:storehouse_id].present?
      @storehouse_id = params[:city][:storehouse_id]
      @engineers = @engineers.where(storehouse_id: @storehouse_id)
    end

    if params[:status].present?
      @engineers = @engineers.where(status: params[:status])
    end

    if params[:level].present?
      @engineers = @engineers.where(level: params[:level])
    end

    @engineers = @engineers.page params[:page]
    index!
  end


  def update
    @engineer = Engineer.find(params[:id])
    params[:engineer][:roles].reject!(&:blank?)
    respond_to do |format|
      if @engineer.update_attributes(params[:engineer])
        format.html { redirect_to user_path(@engineer), notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @engineer.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    create!{ engineers_path }
  end

  protected

  def collection
    page = params[:page] || 1
    get_collection_ivar || set_collection_ivar(end_of_association_chain.page(page))
  end

end
