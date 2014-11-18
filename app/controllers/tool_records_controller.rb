class ToolRecordsController < ApplicationController
  # GET /tool_records
  # GET /tool_records.json
  def index
    if params[:date] && params[:date] == 'today'
      @tool_records = ToolRecord.where(create_date: Date.today)
    else
      @tool_records = ToolRecord.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json {
        if @tool_records.where(engineer_name: current_user.name).exists?
          render json: {result: 'approved'}
        else
          render json: {result: 'not aproved'}
        end
      }
    end
  end

  # GET /tool_records/1
  # GET /tool_records/1.json
  def show
    @tool_record = ToolRecord.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tool_record }
    end
  end

  # GET /tool_records/new
  # GET /tool_records/new.json
  def new
    @tool_record = ToolRecord.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tool_record }
    end
  end

  # GET /tool_records/1/edit
  def edit
    @tool_record = ToolRecord.find(params[:id])
  end

  # POST /tool_records
  # POST /tool_records.json
  def create
    @tool_record = ToolRecord.find_or_create_by :created_at.gte => Date.today.beginning_of_day, :created_at.lte => Date.today.end_of_day, :engineer_name => params[:tool_record][:engineer_name]

    respond_to do |format|
      if @tool_record.update params[:tool_record]
        format.html { redirect_to @tool_record, notice: 'Tool record was successfully created.' }
        format.json { render json: {id: @tool_record.id}, status: :created, location: @tool_record }
      else
        format.html { render action: "new" }
        format.json { render json: @tool_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tool_records/1
  # PUT /tool_records/1.json
  def update
    @tool_record = ToolRecord.find(params[:id])

    respond_to do |format|
      if @tool_record.update_attributes(params[:tool_record])
        format.html { redirect_to @tool_record, notice: 'Tool record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tool_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tool_records/1
  # DELETE /tool_records/1.json
  def destroy
    @tool_record = ToolRecord.find(params[:id])
    @tool_record.destroy

    respond_to do |format|
      format.html { redirect_to tool_records_url }
      format.json { head :no_content }
    end
  end
  
  def uploadpic
    @tool_record = ToolRecord.find(params[:id])
    pic = @tool_record.pictures.create!(p: params[:pic_data])
    respond_to do |format|
      format.html { head :no_content }
      format.json { render json: {result: 'ok', url: pic.p.url }, status: :ok }
    end
  end
end
