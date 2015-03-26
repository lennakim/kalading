class EngineersController < ApplicationController
  inherit_resources

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

end
