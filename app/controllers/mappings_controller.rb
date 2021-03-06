#require "prawn"
require "json"
class MappingsController < ApplicationController
  before_action only: [:create, :destroy]

  # http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @user = current_user
    @mappings = @user.mappings
  end

  def edit
    @mapping = Mapping.find(params[:id])
  end
  
  def show
    @mapping = Mapping.find(params[:id])
    #@entry = Entry.find(params[:field_name])
  end

  def new
    #@mapping = Mapping.new
    @user = current_user
    @mapping = @user.mappings.new
    @mapping.entries.build # build entry attributs
  end

  def create 
    #render plain: params[:mapping].inspect
    #@mapping = Mapping.new(mapping_params)
    @user = current_user
    @mapping = @user.mappings.new(mapping_params)
    if @mapping.save
      flash[:notice] = "Successfully created mapping."
      redirect_to @mapping
    else
      render 'new'
    end
  end

  def update
    @mapping = Mapping.find(params[:id])
    # render plain: params[:mapping].inspect
    if @mapping.update(mapping_params)
      flash[:notice] = "Successfully updated mapping."
      redirect_to @mapping
    else
      render 'edit'
    end
  end 

  def destroy
    @mapping = Mapping.find(params[:id])
    @mapping.destroy
    redirect_to mappings_path
  end

  def download_mapping
    @mapping = Mapping.find(params[:id])
    send_data generate_mapping(@mapping),
              filename: "mapping_#{@mapping.id}.json"
              #type: "application/pdf"
  end
  
  def upload_mapping
    @file = params[:mappingfile].read
    @data = JSON.parse(@file)
    @head = JSON.parse(@data["head"])
    @fields = JSON.parse(@data["fields"])

    @database1=@head["database1"]
    @database2=@head["database2"]

    #save to db ..
    @user = current_user
    @mapping = @user.mappings.new(database1: @database1, database2: @database2, mapping_name: @head["mapping_name"])
    @mapping.save

    #if @mapping.save
    #  flash[:notice] = "Successfully created mapping."
    #end

    @fields.each do |f|
      @field = @mapping.entries.new(tablename: f["tablename"], colname: f["colname"], coltype: f["coltype"], database: f["database"])
      @field.save
    end

    flash[:notice] = "Successfully saved this mapping."

  end


  private
    def mapping_params
      params.require(:mapping).permit(:database1, :database2, :mapping_name)
    end

    def generate_mapping(mapping)
      @json_result=JSON.generate(:head => @mapping.to_json, :fields => @mapping.entries.to_json)

      #Prawn::Document.new do
      #  text "mapping #{mapping.id}" , align: :center
      #  text "database1: #{mapping.database1}"
      #  text "database2: #{mapping.database2}"
      #  mapping.entries.each do |entry|
      #    text "#{entry.tablename} #{entry.colname} #{entry.coltype}"
      #  end
        
      #end.render
    end
end