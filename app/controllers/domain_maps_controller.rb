class DomainMapsController < ApplicationController
  # GET /domain_maps
  # GET /domain_maps.json

  def validate
    @site = DomainMap.find(params[:id])
    @site.validate?(request)

    respond_to do |format|
      if @site.save && @site.verified
        flash[:notice] = 'Site verified!'
        format.html { redirect_to domain_maps_url }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Site verification failed!'
        format.html { redirect_to domain_maps_url }
        format.xml  { render :status => :unprocessable_entity }
      end
    end

  end

  def index
    @domain_maps = DomainMap.where(:user_id.in => organisation_admins)
    @server_ip = server_ip
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @domain_maps }
    end
  end

  # GET /domain_maps/1
  # GET /domain_maps/1.json
  def show
    @domain_map = DomainMap.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @domain_map }
    end
  end

  # GET /domain_maps/new
  # GET /domain_maps/new.json
  def new
    @domain_map = current_user.domain_maps.new
    @server_ip = server_ip
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @domain_map }
    end
  end

  # GET /domain_maps/1/edit
  def edit
    @server_ip = server_ip
    @domain_map = DomainMap.find(params[:id])
  end

  # POST /domain_maps
  # POST /domain_maps.json
  def create
    if params[:domain_map][:domain].blank?
      @req_error = "req_error"
    end
    if params[:domain_map][:map_type] == "organisation" 
      params[:domain_map][:organisation_id] = current_organisation.id
      params[:domain_map][:program_id] = nil
    elsif
      params[:domain_map][:organisation_id] = nil
    end
    @domain_map = current_user.domain_maps.new(params[:domain_map])

    respond_to do |format|
      if @domain_map.save
        format.html { redirect_to domain_maps_url, notice: 'Domain map was successfully created.' }
        format.json { render json: domain_maps_url, status: :created, location: domain_maps_url }
      else
        format.html { render action: "new" }
        format.json { render json: @domain_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /domain_maps/1
  # PUT /domain_maps/1.json
  def update
    if params[:domain_map][:domain].blank?
      @req_error = "req_error"
    end
    @domain_map = DomainMap.find(params[:id])
    params[:domain_map][:verified] = false
    if params[:domain_map][:map_type] == "organisation" 
      params[:domain_map][:organisation_id] = current_organisation.id
      params[:domain_map][:program_id] = nil
    elsif
      params[:domain_map][:organisation_id] = nil
    end
    respond_to do |format|
      if @domain_map.update_attributes(params[:domain_map])
        format.html { redirect_to domain_maps_url, notice: 'Domain map was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @domain_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /domain_maps/1
  # DELETE /domain_maps/1.json
  def destroy
    @domain_map = DomainMap.find(params[:id])
    @domain_map.destroy

    respond_to do |format|
      format.html { redirect_to domain_maps_url }
      format.json { head :no_content }
    end
  end

  private 
  def server_ip 
    Resolv.getaddress request.host
  end

  def organisation_admins
    organisation_admins =[]
    organisation_admins = current_organisation.admins << current_organisation.owner_id.to_s
    organisation_admins = organisation_admins.flatten.uniq
  end
end
