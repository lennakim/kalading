class TestingItemsController < ApplicationController
  inherit_resources
  belongs_to :testing_paper

  def create
    create! { testing_paper_path(parent) }
  end

  def update
    update! { testing_paper_path(parent) }
  end

  def destroy
    destroy! { testing_paper_path(parent) }
  end
end
