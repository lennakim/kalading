class DiscountsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_default_operator
  load_and_authorize_resource
  
  # GET /discounts
  # GET /discounts.json
  def index
    @discounts = Discount.desc(:created_at)
    if params[:discount_token] && params[:discount_token] != ''
      @discounts = @discounts.where(token: /.*#{params[:discount_token]}.*/)
    end
    if params[:name] && params[:name] != ''
      @discounts = @discounts.where(name: /.*#{params[:name]}.*/)
    end
    @discounts = @discounts.page params[:page]
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @discounts }
    end
  end

  # GET /discounts/1
  # GET /discounts/1.json
  def show
    @discount = Discount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @discount }
    end
  end

  def query
    @discount = Discount.find_by token: params[:discount]
    render action: "show"
  end

  # GET /discounts/new
  # GET /discounts/new.json
  def new
    @discount = Discount.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @discount }
    end
  end

  # GET /discounts/1/edit
  def edit
    @discount = Discount.find(params[:id])
  end

  # POST /discounts
  # POST /discounts.json
  def create
    discounts = []
    (1..params[:discount_number].to_i).each do |i|
      if params[:discount_six_length].to_i == 1
        token = ''
        begin
          token = ('A'..'Z').to_a.concat((0..1).to_a).sample(6).join
        end until !Discount.find_by(token: token)
        params[:discount][:token] = token
      else
        params[:discount][:token] = SecureRandom.uuid.delete '-'
      end
      @discount = Discount.new(params[:discount])
      @discount.save
      discounts << @discount
    end
    respond_to do |format|
      format.html { redirect_to discounts_url, notice: I18n.t(:discount_created, n: params[:discount][:name], c: params[:discount_number] ) }
      format.json { render json: discounts, status: :created, location: discounts }
    end
  end

  # PUT /discounts/1
  # PUT /discounts/1.json
  def update
    @discount = Discount.find(params[:id])

    respond_to do |format|
      if @discount.update_attributes(params[:discount])
        format.html { redirect_to @discount, notice: 'Discount was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @discount.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /discounts/1
  # DELETE /discounts/1.json
  def destroy
    @discount = Discount.find(params[:id])
    @discount.destroy

    respond_to do |format|
      format.html { redirect_to discounts_url }
      format.json { head :no_content }
    end
  end
end
