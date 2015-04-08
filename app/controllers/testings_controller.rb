class TestingsController < ApplicationController
  inherit_resources
  belongs_to :engineer

  def create

    paper = TestingPaper.find params[:paper_id]

    if paper.boarding_test? && !parent.can_take_boarding_exam?
      return render text: '你不能参与更多的入职考试'
    end

    testing = parent.testings.create \
      testing_paper_id: paper.id,
      examiner_id:      current_user.id,
      testing_type:     paper.testing_type

    if testing.persisted?
      objs = params[:testing_item].map do |key, value|
        { testing_item_id: key, testing_id: testing.id, pass: value.to_i }
      end

      TestingsItemsMapping.create objs

      begin
        parent.exam
      rescue
        return redirect_to engineer_testing_path(parent, testing)
      end

      redirect_to engineer_boarding_info_path parent
    else
      render text: '出错了'
    end

  end
end
