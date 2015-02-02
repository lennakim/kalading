class TagsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
    @tags = Tag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tags }
    end
  end

  # GET /tags/new
  # GET /tags/new.json
  def new
    @tags = Tag.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tags }
    end
  end

  # GET /tags/1/edit
  def edit
    @tags = Tag.find(params[:id])
  end

  # POST /tags
  # POST /tags.json
  def create
    @tags = Tag.new(params[:user_type])

    respond_to do |format|
      if @tags.save
        format.html { redirect_to @tags, notice: 'User type was successfully created.' }
        format.json { render json: @tags, status: :created, location: @tags }
      else
        format.html { render action: "new" }
        format.json { render json: @tags.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.json
  def update
    @tags = Tag.find(params[:id])

    respond_to do |format|
      if @tags.update_attributes(params[:tag])
        format.html { redirect_to @tags, notice: 'Tag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tags.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tags = Tag.find(params[:id])
    @tags.destroy

    respond_to do |format|
      format.html { redirect_to tags_url }
      format.json { head :no_content }
    end
  end
end
