class ImageTextsController < ApplicationController
  # GET /image_texts
  # GET /image_texts.json
  def index
    @image_texts = ImageText.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @image_texts }
    end
  end

  # GET /image_texts/1
  # GET /image_texts/1.json
  def show
    @image_text = ImageText.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @image_text }
    end
  end

  # GET /image_texts/new
  # GET /image_texts/new.json
  def new
    @image_text = ImageText.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @image_text }
    end
  end

  # GET /image_texts/1/edit
  def edit
    @image_text = ImageText.find(params[:id])
  end

  # POST /image_texts
  # POST /image_texts.json
  def create
    @image_text = ImageText.new(params[:image_text])

    respond_to do |format|
      if @image_text.save
        format.html { redirect_to @image_text, notice: 'Image text was successfully created.' }
        format.json { render json: @image_text, status: :created, location: @image_text }
      else
        format.html { render action: "new" }
        format.json { render json: @image_text.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /image_texts/1
  # PUT /image_texts/1.json
  def update
    @image_text = ImageText.find(params[:id])

    respond_to do |format|
      if @image_text.update_attributes(params[:image_text])
        format.html { redirect_to @image_text, notice: 'Image text was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @image_text.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /image_texts/1
  # DELETE /image_texts/1.json
  def destroy
    @image_text = ImageText.find(params[:id])
    @image_text.destroy

    respond_to do |format|
      format.html { redirect_to image_texts_url }
      format.json { head :no_content }
    end
  end
end
