class MessagesController < ApplicationController
  before_filter :load_program

  def participants
    allowed_params = ["participants", "invited_participants", 
      "mentors", "invited_mentors", "panellists", "invited_panellists",
      "selectors", "invited_selectors", "company_admins"
    ]
    program_id = @program.id.to_s
    if params[:code] == "participant"
      params[:code] = "participants"
    end
    if allowed_params.include?(params[:code])
      if params[:code] == "company_admins"
        @users = User.send(params[:code], current_organisation.id.to_s)
        CommunityFeed.create(created_by: current_user, organisation: 
          current_organisation, program: context_program, content: 
          params[:message], pitch_id: params[:pitch_id] )
        @pitch = Pitch.where(id: params[:pitch_id]).first
        params[:message] += "<br/><br/><a href='#{polymorphic_url([:feeds, context_program, @pitch])}'>Click here to respond.</a>"
        params[:message] = params[:message]
      else
        @users = User.send(params[:code], program_id)
      end
      @users = @users.pluck(:email)
      d("Sending message to #{@users.inspect}")
      #background IT
      Resque.enqueue(App::Background::MessageMailer, @users, 
      params[:subject], params[:message], current_organisation.id) if @users.present?
    end
    redirect_to :back
  end

  def pitches
    if params[:code]  == "pitch_members"
      @users = []
      @users << User.in(:id => Pitch.find(params[:pitch_id]).team).to_a
      @users = @users.flatten
    else
    @users = @program.pitches.collect(&:user)
    if params[:code] == "without_pitches"
      @users = User.participants(@program.id.to_s).to_a - @users
    end 
    end
    @users = @users.compact.collect(&:email)
    d(@users)
    # MessageMailer.message_all(@users, params[:subject], 
    #   params[:message]).deliver if @users.present?
    #background IT
    Resque.enqueue(App::Background::MessageMailer, @users, 
      params[:subject], params[:message], current_organisation.id) if @users.present?
    redirect_to :back
  end
  
  def mentor_pitches
    @pitches = params[:code] == "without_mentor" ? 
      @program.pitches.select{|p| p.mentors.blank?} : 
      @program.pitches.select{|p| p.mentors.present?}
    @users = @pitches.collect(&:user).compact.collect(&:email)
    d(@users)
    # MessageMailer.message_all(@users, params[:subject], 
    #   params[:message]).deliver if @users.present?
    #background IT
    Resque.enqueue(App::Background::MessageMailer, @users, 
      params[:subject], params[:message], current_organisation.id) if @users.present?
    redirect_to :back
  end

  def customize_email_messages
  end

  def feedback_emails
  end

  def feedback_emails_save
    if params[:feedback].present?
      params[:feedback].each_with_index do |feedback, index|
        if @program.customize_admin_emails.where(:from => feedback[0], :email_name => "feedback").present?
          @feedback_mail_update = @program.customize_admin_emails.where(:from => feedback[0], :email_name => "feedback").first
          @feedback_mail_update.update_attributes(:user_id => current_user.id, :email_name=>"feedback", :subject => params[:subject].values[index], :description => feedback[1], :from => feedback[0])
          @feedback_mail_update.save
        else
          @program.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"feedback", :subject => params[:subject].values[index], :description => feedback[1], :from => feedback[0])
          @program.save
        end
      end
      flash[:notice] = "Feedback email updated successfully"
    else
      flash[:error] = "Something goes wrong"
    end    
    redirect_to :back
  end

  def comment_emails
  end

  def comment_emails_save
    if params[:comments].present?
      params[:comments].each_with_index do |comment,index|
        case  index.present?
          when index == 0 then
            comment_list_save("admin",comment)
          when index == 1 then 
           comment_list_save("participant",comment)
          when index == 2 then
            comment_list_save("selector",comment)
          when index == 3 then
            comment_list_save("mentor",comment)
          when index == 4 then
            comment_list_save("panel",comment)
        end
      end
      flash[:notice] = "Comments email updated successfully"
    else
      flash[:error] = "Something goes wrong"
    end
    redirect_to :back
  end

  def admin_invite
    if @program.customize_admin_emails.where(:email_name => "admin_invite").present?
      @admin_mail_update =  @program.customize_admin_emails.where(:email_name => "admin_invite").first.description 
      @admin_subject = @program.customize_admin_emails.where(:from => "admin", :email_name => "admin_invite").first.subject 
    end
  end

  def admin_invite_save
    if @program.customize_admin_emails.where(:email_name => "admin_invite").present?
      @admin_mail_update =  @program.customize_admin_emails.where(:email_name => "admin_invite").first
      @admin_mail_update.update_attributes(:user_id => current_user.id, :email_name=>"admin_invite", :description => params[:feedback][:admin_invite], :from => "admin",:subject=>params[:subject][:admin])
    else
      @program.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"admin_invite", :description => params[:feedback][:admin_invite], :from => "admin",:subject=>params[:subject][:admin])
    end
    redirect_to :back
  end

  def team_member_invite
    if @program.customize_admin_emails.where(:email_name => "team_member_invite").present?
      @team_member =  @program.customize_admin_emails.where(:email_name => "team_member_invite").first.description 
      @team_member_subject = @program.customize_admin_emails.where(:email_name => "team_member_invite").first.subject 
    end
  end

  def team_member_invite_save
    if @program.customize_admin_emails.where(:email_name => "team_member_invite").present?
      @team_member =  @program.customize_admin_emails.where(:email_name => "team_member_invite").first
      @team_member.update_attributes(:user_id => current_user.id, :email_name=>"team_member_invite", :description => params[:feedback][:team_member_invite], :from => "project_member",:subject=>params[:subject][:admin])
    else
      @program.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"team_member_invite", :description => params[:feedback][:team_member_invite], :from => "project_member",:subject=>params[:subject][:admin])
    end
    redirect_to :back
  end

  def team_mentor_invite
    if @program.customize_admin_emails.where(:email_name => "team_mentor_invite").present?
      @team_mentor =  @program.customize_admin_emails.where(:email_name => "team_mentor_invite").first.description 
      @team_mentor_subject = @program.customize_admin_emails.where(:email_name => "team_mentor_invite").first.subject 
    end
  end

  def team_mentor_invite_save
    if @program.customize_admin_emails.where(:email_name => "team_mentor_invite").present?
      @team_mentor =  @program.customize_admin_emails.where(:email_name => "team_mentor_invite").first
      @team_mentor.update_attributes(:user_id => current_user.id, :email_name=>"team_mentor_invite", :description => params[:feedback][:team_mentor_invite], :from => "project_member",:subject=>params[:subject][:admin])
    else
      @program.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"team_mentor_invite", :description => params[:feedback][:team_mentor_invite], :from => "project_member",:subject=>params[:subject][:admin])
    end
    redirect_to :back
  end

  def mentor_offer_invite
    if @program.customize_admin_emails.where(:email_name => "mentor_offer").present?
      @mentor_offer =  @program.customize_admin_emails.where(:email_name => "mentor_offer").first.description 
      @mentor_subject = @program.customize_admin_emails.where(:email_name => "mentor_offer").first.subject 
    end
  end

  def mentor_offer_invite_save
    if @program.customize_admin_emails.where(:email_name => "mentor_offer").present?
      @mentor_offer =  @program.customize_admin_emails.where(:email_name => "mentor_offer").first
      @mentor_offer.update_attributes(:user_id => current_user.id, :email_name=>"mentor_offer", :description => params[:feedback]["mentor_offer"], :from => "mentor",:subject=>params[:subject][:admin])
    else
      @program.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"mentor_offer", :description => params[:feedback]["mentor_offer"], :from => "mentor",:subject=>params[:subject][:admin])
    end
    redirect_to :back
  end

  def join_team
    if @program.customize_admin_emails.where(:email_name => "join_team").present?
      @join_team =  @program.customize_admin_emails.where(:email_name => "join_team").first.description 
      @join_team_subject = @program.customize_admin_emails.where(:email_name => "join_team").first.subject 
    end
  end

  def join_team_save
    if @program.customize_admin_emails.where(:email_name => "join_team").present?
      @join_team =  @program.customize_admin_emails.where(:email_name => "join_team").first
      @join_team.update_attributes(:user_id => current_user.id, :email_name=>"join_team", :description => params[:feedback]["join_team"], :subject=>params[:subject][:join_team])
    else
      @program.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"join_team", :description => params[:feedback]["join_team"], :subject=>params[:subject][:join_team])
    end
    redirect_to :back
  end

  def submit_pitch
    unless @program.customize_admin_emails.where(:email_name => "submit_pitch").present?
      @program.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"submit_pitch", :description =>"<div>Dear team #projectname<br></div><div><br></div><div>Thanks a lot for submitting your #projectsemantic.<br></div><div><br></div><div>The jury will soon be voting and we will come back to you as soon as this is done!<br></div><div><br></div><div>#programname<br></div>", :subject=>"Thanks for submitting your project!")
    end
    @submit_pitch =  @program.customize_admin_emails.where(:email_name => "submit_pitch").first.description 
    @submit_pitch_subject = @program.customize_admin_emails.where(:email_name => "submit_pitch").first.subject
  end

  def submit_pitch_save
    if @program.customize_admin_emails.where(:email_name => "submit_pitch").present?
      @submit_pitch =  @program.customize_admin_emails.where(:email_name => "submit_pitch").first
      @submit_pitch.update_attributes(:user_id => current_user.id, :email_name=>"submit_pitch", :description => params[:feedback]["submit_pitch"], :subject=>params[:subject][:submit_pitch])
    else
      @program.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"submit_pitch", :description => params[:feedback]["submit_pitch"], :subject=>params[:subject][:submit_pitch])
    end
    redirect_to :back
  end

  def collaboration_successfull
    if @program.customize_admin_emails.where(:email_name => "collaboration_successfull").present?
      @coll_succ =  @program.customize_admin_emails.where(:email_name => "collaboration_successfull").first.description 
      @coll_succ_subject = @program.customize_admin_emails.where(:email_name => "collaboration_successfull").first.subject 
    end
  end

  def collaboration_successfull_save
    if @program.customize_admin_emails.where(:email_name => "collaboration_successfull").present?
      @join_team =  @program.customize_admin_emails.where(:email_name => "collaboration_successfull").first
      @join_team.update_attributes(:user_id => current_user.id, :email_name=>"collaboration_successfull", :description => params[:feedback]["collaboration_successfull"], :subject=>params[:subject][:collaboration_successfull])
    else
      @program.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"collaboration_successfull", :description => params[:feedback]["collaboration_successfull"], :subject=>params[:subject][:collaboration_successfull])
    end
    redirect_to :back
  end

  def msg_pitch_team
    @users = []
    pitch = Pitch.find(params[:pitch_id])
    @users << User.in(:id => (pitch.members + pitch.mentors + pitch.collaboraters))
    @users << pitch.user
    @users = @users.flatten
    @users = @users.compact.collect(&:email)
    d(@users)
    # MessageMailer.message_all(@users, params[:subject], 
    #   params[:message]).deliver if @users.present?
    #background IT
    @program.activity_feeds.create(:type=>"push_notification", user_id: current_user.id, pitch_id: pitch.id, message: params[:message])
    Resque.enqueue(App::Background::MessageMailer, @users, 
      params[:subject], params[:message], current_organisation.id) if @users.present?
    redirect_to :back
  end

  def download_csv
    begin
    @users = @program.pitches.collect(&:user)
    @users = User.participants(@program.id.to_s).to_a - @users
    csv_string = CSV.generate do |csv|
      csv << ["Sno.", "First Name", "Last Name", "Email"]
      index = 0
      @users.each do |user|
        index += 1
        csv << [index, user.first_name, user.last_name, user.email] if user
      end
    end
  
    send_data csv_string,
    :type => 'text/csv; charset=iso-8859-1; header=present',
    :disposition => "attachment; filename=#{t("role_type:participant", "p")}-without-pitches.csv"
    rescue Exception => e
      flash[:notice] = "#{e.message}"
      redirect_to :back and return
    end
  end
  
  def phase_messages
    @users = []
    @pitches = @program.workflows.on.where(phase_name: params[:phase_name]).map(&:pitch_phases).flatten.map(&:pitch)
    if params[:phase_type] == "out_of_phase"
      @pitches = @program.pitches.nin(:id => @pitches.map(&:id))
    end
    if @pitches
      @pitches.each do |pitch|
        users = User.in(id: pitch.team).map(&:email)
        if users.present?
            @users << users
        end
      end 
    end
    @users = @users.flatten.uniq
    d(@users)
    Resque.enqueue(App::Background::MessageMailer, @users, 
    params[:subject], params[:message], current_organisation.id) if @users.present?
    redirect_to :back and return
  end
  
  def join_team_email
    if @program.customize_admin_emails.where(:email_name => "join_team_email").present?
      @join_team_message =  @program.customize_admin_emails.where(:email_name => "join_team_email").first.description 
      @join_team_subject = @program.customize_admin_emails.where(:email_name => "join_team_email").first.subject 
    end
  end

  def join_team_email_save
    if @program.customize_admin_emails.where(:email_name => "join_team_email").present?
      @join_team =  @program.customize_admin_emails.where(:email_name => "join_team_email").first
      @join_team.update_attributes(:user_id => current_user.id, :email_name=>"join_team_email", :description => params[:feedback]["join_team_email"], :subject=>params[:subject][:join_team_email])
    else
      @program.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"join_team_email", :description => params[:feedback]["join_team_email"], :subject=>params[:subject][:join_team_email])
    end
    redirect_to :back
  end

  def declines_join_team_request
    if @program.customize_admin_emails.where(:email_name => "declines_join_team_request").present?
      @declines_join_team_subject =  @program.customize_admin_emails.where(:email_name => "declines_join_team_request").first.subject
      @declines_join_team_message = @program.customize_admin_emails.where(:email_name => "declines_join_team_request").first.description
    end
  end

  def declines_join_team_request_save
    if @program.customize_admin_emails.where(:email_name => "declines_join_team_request").present?
      @join_team =  @program.customize_admin_emails.where(:email_name => "declines_join_team_request").first
      @join_team.update_attributes(:user_id => current_user.id, :email_name=>"declines_join_team_request", :description => params[:feedback]["declines_join_team_request"], :subject=>params[:subject][:declines_join_team_request])
    else
      @program.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"declines_join_team_request", :description => params[:feedback]["declines_join_team_request"], :subject=>params[:subject][:declines_join_team_request])
    end
    redirect_to :back
  end

  def rate_events_mail
    if @program.customize_admin_emails.where(:email_name => "rate_events").present?
      @rate_events_subject =  @program.customize_admin_emails.where(:email_name => "rate_events").first.subject
      @rate_events_message = @program.customize_admin_emails.where(:email_name => "rate_events").first.description
    end
  end

  def rate_events_mail_save
    if @program.customize_admin_emails.where(:email_name => "rate_events").present?
      @mail =  @program.customize_admin_emails.where(:email_name => "rate_events").first
      @mail.update_attributes(:user_id => current_user.id, :email_name=>"rate_events", :description => params[:feedback]["rate_events_mail"], :subject=>params[:subject][:rate_events_mail])
    else
      @program.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"rate_events", :description => params[:feedback]["rate_events_mail"], :subject=>params[:subject][:rate_events_mail])
    end
    redirect_to :back
  end

  private

  def comment_list_save(user_type,comment)
    if comment[0].present?
      if comment[1][:comment].present? ||  comment[1][:subject].present?
        comment[1][:comment].each_with_index do |new_comment, index|
          if @program.customize_admin_emails.where(:from => user_type , :to => new_comment[0], :email_name => "comments").present?
            @comment_mail_update = @program.customize_admin_emails.where(:from => user_type, :to => new_comment[0], :email_name => "comments").first
            @comment_mail_update.update_attributes(:user_id => current_user.id, :email_name=>"comments", :subject => comment[1][:subject].values[index], :description => new_comment[1], :from => user_type, :to => new_comment[0])
            @comment_mail_update.save
          else
            @program.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"comments", :subject => comment[1][:subject].values[index], :description => new_comment[1], :from => user_type, :to => new_comment[0])
            @program.save
          end
        end
      end
    end
  end

  def load_program
    @program = Program.find(params[:program_id])
  end
end