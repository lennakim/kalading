class EngineersController < ApplicationController
  inherit_resources

  def index
    @engineers = Engineer.all

    if params[:name].present?
      @engineers = @engineers.where(name: /.*#{params[:name]}.*/i)
    end

    if params[:phone_num].present?
      @engineers = @engineers.where(phone_num: /.*#{params[:phone_num]}.*/i)
    end

    if params[:work_tag_number].present?
      @engineers = @engineers.where(work_tag_number: /.*#{params[:work_tag_number]}.*/i)
    end

    if params[:city_id].present?
      @engineers = @engineers.where(city_id: params[:city_id])
    end

    if params[:city] && params[:city][:storehouse_id].present?
      @storehouse_id = params[:city][:storehouse_id]
      @engineers = @engineers.where(storehouse_id: @storehouse_id)
    end

    if params[:level].present?
      @engineers = @engineers.where(level: params[:level])
    end

    if params[:aasm_state].present?
      @engineers = @engineers.where(aasm_state: params[:aasm_state])
    end

    @engineers = @engineers.page params[:page]
    index!
  end

  def create
    create!{ engineers_path }
  end

  def take_exam
    @engineer = Engineer.find params[:engineer_id]
    @paper = TestingPaper.find params[:paper_id]
  end

  def boarding_info

  end

  protected

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.page(page))
  end

end
