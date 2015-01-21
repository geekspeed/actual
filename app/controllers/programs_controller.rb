class ProgramsController < ApplicationController

  before_filter :authorize_admin, :except => [:show, :promotion, :program_login, :contact_us, :user_badges]
  skip_before_filter :authenticate_user!, :only => [:show, :promotion, :program_login, :contact_us]
  
  def new
    @program = Program.new(:organisation => current_organisation)
  end

  def create
    @program = Program.new(merge_tags)
    @program.organisation = current_organisation
    if @program.save
      flash[:notice] = "Program created successfully."
      redirect_to new_program_summary_path(@program)
    else
      render :action => :new
    end
  end

  def show
    @program = Program.find(params[:id])
    redirect_to root_path and return if @program.master_program?
    render layout: "program_summary"
  end

  def program_login
    @program = Program.find(params[:id])
    render layout: 'view_program'
  end

  def promotion
    @program = Program.find(params[:id])
    # @program.includes(:program_summary)
    render layout: 'promotion'
  end

  def edit
    @program = Program.find(params[:id])
    (redirect_to root_path and return) if (@program.master_program? && !current_user.company_admin?(@program.organisation))
  end

  def update
    @program = Program.find(params[:id])
    if @program.update_attributes(merge_tags)
      flash[:notice] = "Program updated successfully."
      redirect_to :back
    else
      render :action => :edit
    end
  end

  def destroy
    @program = Program.find(params[:id])
    @program.destroy
    redirect_to :back
  end

  
  def awaiting_users
    @program = Program.find(params[:id])
    @participants = User.where(:"_awaiting_participant".in => [@program.id.to_s])
    @rejected_participants = User.where(:"_rejected_participant".in => [@program.id.to_s])
    @mentors = User.where(:"_awaiting_mentor".in => [@program.id.to_s])
    @rejected_mentors = User.where(:"_rejected_mentor".in => [@program.id.to_s])
  end

  def approve_user
    @program = Program.find(params[:id])
    user = User.find(params[:user_id])
    user.remove_role "awaiting_#{params[:role]}", @program.id.to_s
    user.add_role params[:role], @program.id.to_s
    activity_feed = @program.activity_feeds.where(user_id: user.id, role_code: params[:role], awaiting: true, type: "join_program").first
    activity_feed.update_attribute(:awaiting, false) if activity_feed
    welcome_messages(user.id, @program, params[:role]) if @program.program_invitation
    redirect_to :back
  end

  def decline_user
    @program = Program.find(params[:id])
    user = User.find(params[:user_id])
    user.remove_role "awaiting_#{params[:role]}", @program.id.to_s
    user.add_role "rejected_#{params[:role]}", @program.id.to_s
    User.rejection_message(user.id, params[:role], @program.id)
    redirect_to :back
  end

  def contact_us
    program = Program.find(params[:program_id])
    from = params[:email]
    name = params[:user_name]
    subject = params[:title]
    body = params[:description]
    if simple_captcha_valid?
      Resque.enqueue(App::Background::ProgramContactUs, params[:program_id], from, name, subject, body)
      redirect_to :back, :notice => "Message sent successfully"
    else
      redirect_to :back, :notice => "The secret Image and code were different."
    end
  end

  def manage_form
    @program= Program.find(params[:program_id])
    @survey = params[:survey_id] ? Survey.where(:id => params[:survey_id]).first : @program.surveys.first
  end
  
  def manage_form_save
    @program = Program.where(:id => params[:program_id]).first
    @survey = Survey.where(:id => params["survey_id"]).first
    @survey.update_attributes(:time => params["time"])
    @survey.recurring_period = params[:recurring_period]
    @survey.recurring_period_update = Time.now if @survey.recurring_period_changed?
    @survey.save
    redirect_to program_manage_form_path(@program, survey_id:@survey.id )
  end

  def change_feed_form
    survey = Survey.where(:id => params[:survey_id]).first
    @program = survey.program
    render :partial => "programs/feed_form", :locals => {survey: survey}
  end

  def feed_form
    survey = Survey.where(:id => params[:survey_id]).first
    survey.update_attributes(params[:survey])
    Resque.enqueue(App::Background::SurveyMail, params[:survey_id],current_user.id) if (survey.visibility.include?("email") and survey.category == "One-Off")
    if !survey.audience_completed_survey.include?(current_user.id)
      activity_feed = ActivityFeed.find_or_initialize_by(survey_id: survey.id)
      activity_feed.update_attributes(:type=>"survey", :user_id => survey.user.id, :program_id => params[:program_id])
    end
    redirect_to program_manage_form_path(survey.program, survey_id:survey.id )
  end
  
  def dashboard
    @program = Program.find(params[:program_id])
    @awating_participants = User.where(:"_awaiting_participant".in => [@program.id.to_s]).count
    @awating_mentors = User.where(:"_awaiting_mentor".in => [@program.id.to_s]).count
  end

  def download_phase_in_csv
    @program = Program.find(params[:id])
    phase_name = params[:phase_name]
    phase_type = params[:phase_type]
    begin
      @pitch_map= @program.workflows.on.where(phase_name:  phase_name).map(&:pitch_phases).flatten.map(&:pitch)
      if phase_type == "out_of_phase"
        @pitch_map = @program.pitches.nin(:id => @pitch_map.map(&:id))
      end
      csv_string = User.pitch_to_csv(@pitch_map, @program.id)
      send_data csv_string,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{phase_name.parameterize}_#{phase_type}.csv"
    rescue Exception => e
      flash[:notice] = "#{e.message}"
      redirect_to :back and return
    end
  end
  
  def export_users_detail
    begin
    @program = Program.find(params[:program_id])
    role = "_#{params[:role]}"
    role_invite = "_invited_#{params[:role]}"
    role_rejected = "_rejected_#{params[:role]}"
    role_awaiting = "_awaiting_#{params[:role]}"
    anchor = params[:role] == "participant" ? "participant" : "mentor"
    @users = User.or(role => @program.id.to_s).or(role_invite => @program.id.to_s).or(role_rejected => @program.id.to_s).or(role_awaiting => @program.id.to_s)
    csv_string = User.to_csv(@users.flatten.uniq, params[:role], @program, anchor)
  
    send_data csv_string,
    :type => 'text/csv; charset=iso-8859-1; header=present',
    :disposition => "attachment; filename=#{params[:role]}.csv"
    rescue Exception => e
      flash[:notice] = "#{e.message}"
      redirect_to :back and return
    end
  end
  
  def export_projects_detail
    begin
    @program = Program.find(params[:program_id])
    @pitches = @program.pitches
    csv_string = User.pitch_to_csv(@pitches, @program.id)
  
    send_data csv_string,
    :type => 'text/csv; charset=iso-8859-1; header=present',
    :disposition => "attachment; filename=projects.csv"
    rescue Exception => e
      flash[:notice] = "#{e.message}"
      redirect_to :back and return
    end
  end

  def delete_user
    @program = Program.find(params[:id])
    user = User.find(params[:user_id])
    if user and user.destroy
      flash[:notice] = "Removed Successfully"
    end
    redirect_to :back
  end

  def get_action_list
    @program = Program.find(params[:program_id])
    @pitches = @program.workflows.where(id: params[:workflow_id]).map(&:pitch_phases).flatten.map(&:pitch)
    if params[:data_type] == "out_of_phase"
      @pitches = @program.pitches.nin(:id => @pitches.map(&:id))
    end
    @tasks = []
    @pitches.each do |pitch|
      @tasks << pitch.milestones.first.tasks.where(:complete => false)
    end
    @tasks = @tasks.flatten.uniq
    render layout: false
  end

  def community_tab
    @program = Program.find(params[:program_id])
    @custom_filter = CustomFilter.find_or_create_by(:program_id => context_program.id.to_s, ankor: "participant")
    @custom_filter_for_mentor = CustomFilter.find_or_create_by(:program_id => context_program.id.to_s, ankor: "mentor")
  end
  
  def update_custom_filter
    @custom_filter = CustomFilter.find(params[:filter_id])
    if @custom_filter.update_attributes(params[:custom_filter])
      flash[:notice] = "Program updated successfully."
    end
    redirect_to polymorphic_path([context_program, :community_tab])
  end

  def delete_rule
    custom_rule = CustomRule.where(:id => params[:custom_rule_id]).first
    if custom_rule.destroy
      flash[:notice] = "Rule deleted Successfully"
    else
      flash[:notice] = "Problem deleting Rule"
    end
    redirect_to :back
  end
  
  def get_rule
    @program = context_program
    @custom_rule = CustomRule.find(params[:rule_id])
    render layout: false
  end
  
  def update_rule
    @custom_rule = CustomRule.find(params[:rule_id])
    if @custom_rule.update_attributes(params[:custom_rule])
      flash[:notice] = "Rule updated Successfully"
    else
      flash[:notice] = "Error updating rule"
    end
    redirect_to polymorphic_path([context_program, :community_tab])
  end

  def manage_badges
    @app_badges = context_program.app_badges
    @program_users = User.or(:"_participant".in=> [context_program.id.to_s]).or(:"_mentor".in=> [context_program.id.to_s]).or(:"_selector".in=> [context_program.id.to_s]).or(:"_panellist".in=> [context_program.id.to_s]).flatten.uniq
  end

  def issued_badges
    @app_badge = AppBadge.where(id: params[:app_badge]).first
    @user_badges=@app_badge.user_badges.in(active: true)
  end
  def revoke_user_badge
    user_badge=UserBadge.where(id: params[:user_badge]).first
    if user_badge.revoked
     user_badge.update_attributes(revoked: false)
     render json: { status: "ok", revoked: "Revoke" } 
    else
     user_badge.update_attributes(revoked: true)
     render json: { status: "ok", revoked: "Revoked" }
    end
        
  end

  private

  def merge_tags
    params[:tags].present? ? params[:program].merge(params[:tags]) : 
      params[:program]
  end

  def welcome_messages(user_id, program, role)
    program_invitation_mail = ProgramInvitation.where(:program_id => program.id).last.program_invitation_mail
    case role
    when "participant"
      @welcome_message = program_invitation_mail.applicant_message["applicant_welcome"]
    when "mentor"
      @welcome_message = program_invitation_mail.mentors_message["mentors_welcome"]
    end
    User.welcome_messages(user_id, role, @welcome_message, program.id)
  end

  def authorize_admin
    if current_user.program_admin?(current_organisation) || current_user.company_admin?(current_organisation)
      return true
    else
      raise App::Rolefy::NotAuthorized, "Need a Company or Program Admin"
    end
  end

end
