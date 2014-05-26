class ToolTypesController < ApplicationController
  # GET /tool_types
  # GET /tool_types.json
  def index
    @tool_types = ToolType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tool_types }
    end
  end

  # GET /tool_types/1
  # GET /tool_types/1.json
  def show
    @tool_type = ToolType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tool_type }
    end
  end

  # GET /tool_types/new
  # GET /tool_types/new.json
  def new
    @tool_type = ToolType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tool_type }
    end
  end

  # GET /tool_types/1/edit
  def edit
    @tool_type = ToolType.find(params[:id])
  end

  # POST /tool_types
  # POST /tool_types.json
  def create
    @tool_type = ToolType.new(params[:tool_type])

    respond_to do |format|
      if @tool_type.save
        format.html { redirect_to @tool_type, notice: 'Tool type was successfully created.' }
        format.json { render json: @tool_type, status: :created, location: @tool_type }
      else
        format.html { render action: "new" }
        format.json { render json: @tool_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tool_types/1
  # PUT /tool_types/1.json
  def update
    @tool_type = ToolType.find(params[:id])

    respond_to do |format|
      if @tool_type.update_attributes(params[:tool_type])
        format.html { redirect_to @tool_type, notice: 'Tool type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tool_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tool_types/1
  # DELETE /tool_types/1.json
  def destroy
    @tool_type = ToolType.find(params[:id])
    @tool_type.destroy

    respond_to do |format|
      format.html { redirect_to tool_types_url }
      format.json { head :no_content }
    end
  end
end
