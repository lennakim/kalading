class ToolStocksController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @tool_stocks = ToolStock.page(params[:page]).per(20)
  end
end
