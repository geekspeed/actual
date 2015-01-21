class ProgramSummariesController < ApplicationController

  before_filter :load_program, :except => [:create_eventbrite_account]
  before_filter :load_eventbrite_creds, only: [:authorize_eventbrite_account, :create_eventbrite_account,
                                                  :fetch_eventbrite_events, :create_eventbrite_events]

  def new
    @summary = @program.build_program_summary
    @summary.program_plans.build
    @summary.program_partners.build
    @summary.program_quotes.build
    @summary.build_program_summary_customization
    @summary.build_program_summary_order
    @summary.program_free_forms.build
    @summary.case_studies.build
  end

  def create
    d(merge_tags)
    @summary = @program.build_program_summary(merge_tags)
    params[:program_summary][:free_form].each do|title, value|
      free_form = ProgramFreeForm.find_or_initialize_by(:program_summary_id => @summary.id, :section_title => title)
      free_form.update_attributes(:body => value[:body])
    end
    if @summary.save
      redirect_to new_program_scope_path(@program)
    else
      render :action => :new
    end
  end

  def edit
    @summary = @program.program_summary
  end

  def update
    @summary = @program.program_summary
    if !@summary.program_summary_customization.present?
      @summary.build_program_summary_customization
    end
    if !@summary.program_summary_order.present?
      @summary.build_program_summary_order(:order => params[:program_summary_program_summary_order_attributes_order])
    end
    params[:program_summary][:free_form].each do|title, value|
      free_form = ProgramFreeForm.find_or_initialize_by(:program_summary_id => @summary.id, :section_title => title)
      free_form.update_attributes(:body => value[:body])
    end
    if @summary.update_attributes(merge_tags)
      create_program_summary_semantics(params[:semantics])
      flash[:notice] = "Program summary updated successfully."
      redirect_to :back
    else
      render :action => :edit
    end
  end

  def authorize_eventbrite_account
    session[:evenbrite_program_id] = params[:program_id]
    session[:request_host] = request.host
    redirect_to "https://www.eventbrite.com/oauth/authorize?response_type=code&client_id=#{@eventbrite_key}" unless params[:code]
  end

  def create_eventbrite_account
    begin
      Rails.logger.warn "#{session} #{context_program.try(:id)}"
      @program = Program.find(session.delete(:evenbrite_program_id)) if session[:evenbrite_program_id].present?
      if params[:code]
        response = RestClient.post 'https://www.eventbrite.com/oauth/token', :code => params[:code], :client_secret => @eventbrite_oauth_token, :client_id => @eventbrite_key, :grant_type => 'authorization_code'
        parsed_response = JSON.parse response
        eb_auth_tokens = { app_key: @eventbrite_key, access_token: parsed_response["access_token"]}
        @eb_client = EventbriteClient.new(eb_auth_tokens)
        @eb_user = @eb_client.user_get()
        @summary = @program.program_summary
        @summary.add_to_keys! parsed_response["access_token"], @eb_user["user"]["email"]
      end
      redirect_to edit_program_summary_path(@program)
    rescue Exception => e
      Rails.logger.warn "EventBrite Error: #{e.message}"
      redirect_to root_path
    end
  end

  def fetch_eventbrite_events
    unless get_eventbrite_user
      render :json => {:status => "Invalid User Key"}
    else
      unless get_eventbrite_events
        render :json => {:status => "No events found for this user."}
      else
        @user_token = params[:user_token]
        @events = @eb_events["events"]
         render :partial => '/program_summaries/eventbrite_events'
      end
    end
  end

  def create_eventbrite_events
    @summary = @program.program_summary
    evenbrite_user = get_eventbrite_user
    params[:event_ids].each do |event_id|
      event = @eb_client.event_get({:id => event_id})["event"]
      old_plan = @summary.program_plans.where(eventbrite_id: event["id"]).first
      if old_plan
        old_plan.update_attributes(date_from: event["start_date"], date: event["end_date"].to_date, time_from: event["start_date"].to_time.strftime("%H:%M"), time_to: event["end_date"].to_time.strftime("%H:%M"), activity: event["title"], location: ActionView::Base.full_sanitizer.sanitize(event["description"]), eventbrite_id: event["id"], eventbrite_event_url: event["url"], user_access_token: params[:user_token])
      else
        @summary.program_plans.create(date_from: event["start_date"], date: event["end_date"].to_date, time_from: event["start_date"].to_time.strftime("%H:%M"), time_to: event["end_date"].to_time.strftime("%H:%M"), activity: event["title"], location: ActionView::Base.full_sanitizer.sanitize(event["description"]), eventbrite_id: event["id"], eventbrite_event_url: event["url"], user_access_token: params[:user_token])
      end
    end
    render :json => {:status => "ok"}
  end

  def partner_destroy
    @program_partner = ProgramPartner.find params[:program_partner_id]
    if @program_partner.destroy
      flash[:notice] = "Program Partner Destroyed"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  def quote_destroy
    @program_quote = ProgramQuote.find params[:program_quote_id]
    if @program_quote.destroy
      flash[:notice] = "Program Quote Destroyed"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  def case_study_destroy
    @program_case_study = CaseStudy.find params[:case_study_id]
    if @program_case_study.destroy
      flash[:notice] = "Case Study Destroyed"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  def free_form_destroy
    if !params[:free_form_section_id].blank?
      @program_free_form = ProgramFreeForm.where(:section_id => params[:free_form_section_id])
    else
      @program_free_form = ProgramFreeForm.find params[:free_form_id]
    end    
    
    if @program_free_form.destroy
      flash[:notice] = "Program Free Form Destroyed"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  def generate_nav_links
    params[:navlinks].each do|nav_link|
      nav_link[:custom_url] ||= false
      nav_link_obj = ProgramNavLink.find_or_initialize_by(:program_id => context_program.id, :order => nav_link[:order])
      nav_link[:name].present? ? nav_link_obj.update_attributes(:url => nav_link[:url].split("//").last, :custom_url => nav_link[:custom_url], :name => nav_link[:name]) : nav_link_obj.destroy 
    end
    redirect_to :back
  end
  
  private

  def load_program
    @program = Program.find(params[:program_id]) if params[:program_id].present?
  end

  def merge_tags
    params[:tags].present? ? params[:program_summary].merge(params[:tags]) : 
      params[:program_summary]
  end

  def get_eventbrite_user
    begin
      eb_auth_tokens = { app_key: @eventbrite_key,access_token: params[:user_token]}
      @eb_client = EventbriteClient.new(eb_auth_tokens)
      @eb_user = @eb_client.user_get()
    rescue Exception => e
      return false
    end
  end

  def get_eventbrite_events
    begin
      @eb_events = @eb_client.user_list_events()
    rescue Exception => e
      return false
    end
  end

  def create_program_summary_semantics(semantics)
    semantics.each do |key, semantic|
      Semantic.for_program(@program.id).find_or_create_by(key: 
        key).update_attributes(semantic)
    end if semantics
  end

  def load_eventbrite_creds
    domain = mapped_url(request.host)
    @eventbrite_key = domain.try(:eventbrite_app_key) || EventBrite_KEY
    @eventbrite_oauth_token = domain.try(:eventbrite_oauth_client_secret) || EvenBrite_secret
  end

end
