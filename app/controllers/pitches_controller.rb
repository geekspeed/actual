class PitchesController < ApplicationController

  before_filter :load_program
  
  def show
    @pitch = @program.pitches.find(params[:id])
    render :edit, :layout => "application_new_design"
  end

  def new
    if need?(["participant"], context_program) and context_program.try(:program_scope).try(:stop_adding_project_participants)
        redirect_to root_path
    else
      @pitch = @program.pitches.build(:user => current_user)
      render :layout => "application_new_design"
    end
  end

  def create
    @pitch = @program.pitches.build(params[:pitch])
    my_params = upload_custom_field(params[:pitch][:custom_fields], @pitch)
    (my_params = gallery_custom_field(my_params, params[:gallery_custom_fields], @pitch)) if !params[:gallery_custom_fields].blank?
    render :action => :new and return unless @pitch.errors.blank?
    @pitch.custom_fields = my_params
    @pitch.user = current_user
    #for storing the activity details
    @program.activity_feeds.create(:type=>"pitch_create", :pitch_id => @pitch.id, :user_id => current_user.id)
    @program.activity_feeds.create(:type=>"pitch_create_program", :pitch_id => @pitch.id, :user_id => current_user.id)
    if @pitch.save
      pitch_main_url = (@program.try(:course_setting).try(:user_section) == "course_show" && !@program.course.blank? && @program.courses_part_of_program) ? polymorphic_url([@program, @pitch, @program.course, :show]) : program_pitch_path(@program, @pitch)
      redirect_to pitch_main_url
    else
      render :action => :new
    end
  end

  def edit
    @pitch = @program.pitches.find(params[:id])
    render :layout => "application_new_design"
  end

  def update
    @pitch = @program.pitches.find(params[:id])
    if @pitch.update_attributes(params[:pitch])
      flash[:notice] = "Pitch has been updated"
      redirect_to :back
    else
      render :action => :edit
    end
  end

  def destroy
    @pitch = @program.pitches.find(params[:id])
    if current_user.company_admin?(current_organisation) || @pitch.owner?(current_user)
      @pitch.destroy
    else
      flash[:error] = "You are not authorized to delete this pitch."
    end
    redirect_to root_path
  end

  def iteration
    @pitch = @program.pitches.find(params[:id])
    if @pitch.summary.update_attributes(:content => params[:content])
      flash[:notice] = "Pitch has been updated"
    end
    redirect_to :back
  end

  def nudge
    @pitch = @program.pitches.find(params[:id])
    message_body = <<-END
      Hi There,</br></br>

      Please update milestone to back maximum backing for
      your pitch <a href='#{program_pitch_path(@program, @pitch)}'>#{@pitch.title}</a>
    END
    d(User.in(:id  => @pitch.members).collect(&:email).inspect)
    @emails = [@pitch.user.email] + User.find(@pitch.members).collect(&:email)
    # MessageMailer.message_all(@emails, "Please update your milestones",
       # message_body).deliver if @emails.present?
    #background IT
    Resque.enqueue(App::Background::MessageMailer, @emails, 
      "Please update your milestones", message_body.html_safe, current_organisation.id) if @emails.present?
    redirect_to :back
  end

  def be_mentor
    @pitch = @program.pitches.find(params[:id])
    @pitch.add_to_contacts!(current_user)
    @all_team_members = []
    @all_team_members  <<  User.in(:id  => @pitch.members)
    @all_team_members  << @pitch.user
    @mentor = current_user
    @pitch.mentor_offer(@mentor.id , @pitch.id, @all_team_members.flatten)
    @program.activity_feeds.create(:type=>"be_pitch_mentor", :user_id => current_user.id, :pitch_id=> @pitch.id)
    redirect_to :back
  end

  def join_team
    @pitch = @program.pitches.find(params[:id])
    @pitch.add_to_membership_requesters!(current_user)
    @all_team_members = []
    @all_team_members  << @pitch.user
    @program.restrict_team_management ?  @all_team_members : (@all_team_members  <<  User.in(:id => @pitch.members))
    @new_team_member = current_user
    @pitch.join_team(@new_team_member.id , @pitch.id, @all_team_members.flatten)
    @program.restrict_team_management ? "" : (@program.activity_feeds.create(:type=>"join_team", :user_id => current_user.id, :pitch_id=> @pitch.id))
    flash[:notice] = "#{Workspace.workspace_sementic("to_do_list_join_this_team_txt","I would like to join this team", context_program)} request has been sent"
    redirect_to :back
  end
  

  def contacts
    @pitch = @program.pitches.find(params[:id])
    @contacts = User.find(@pitch.contacts)
    @membership_requesters = User.find(@pitch.membership_requesters)
    @collaborater_requesters = User.find(@pitch.collaborate_requesters)
    render layout: "application_new_design"
  end

  def add_mentor
    @pitch = @program.pitches.find(params[:id])
    @pitch.remove_from_contacts!(params[:user_id])
    @pitch.add_to_mentors!(params[:user_id])
    @program.activity_feeds.create(:type=>"pitch_mentor", :user_id => params[:user_id], :pitch_id=> @pitch.id)
    feed = @program.activity_feeds.where(type: "be_pitch_mentor", user_id: params[:user_id], pitch_id: @pitch.id).first
    if feed
       feed.update_attributes(response: "accepted")
    end
    Resque.enqueue(App::Background::MentorOfferResponse, @pitch.id, params[:user_id], "Added", @pitch.program_id, @pitch.program.class.to_s)
    flash[:notice] = "Mentor Added Successfully"
    redirect_to :back
  end

  def remove_mentor
    @pitch = @program.pitches.find(params[:id])
    @pitch.remove_from_contacts!(params[:user_id])
    feed = @program.activity_feeds.where(type: "be_pitch_mentor", user_id: params[:user_id], pitch_id: @pitch.id).first
    if feed
       feed.update_attributes(response: "declined")
    end
    Resque.enqueue(App::Background::MentorOfferResponse, @pitch.id, params[:user_id], "Removed", @pitch.program_id, @pitch.program.class.to_s)
    flash[:notice] = "Mentor Request Removed Successfully"
    redirect_to :back
  end

  def add_membership_requester
    @pitch = @program.pitches.find(params[:id])
    @pitch.remove_from_membership_requesters!(params[:user_id])
    @pitch.add_to_members!(params[:user_id])
    #for storing the activity details
    @program.activity_feeds.create(:type=>"pitch_member", :user_id => params[:user_id], :pitch_id=> @pitch.id)
    feed = @program.activity_feeds.where(type: "join_team", user_id: params[:user_id], pitch_id: @pitch.id).first
    if feed
       feed.update_attributes(response: "accepted")
    end
    Resque.enqueue(App::Background::MemberJoinedTeam,params[:user_id] , @pitch.id)
    flash[:notice] = "Member added successfully"
    redirect_to :back
  end
  
	

  def remove_membership_requester
    @pitch = @program.pitches.find(params[:id])
    @pitch.remove_from_membership_requesters!(params[:user_id])
    feed = @program.activity_feeds.where(type: "join_team", user_id: params[:user_id], pitch_id: @pitch.id).first
    if feed
       feed.update_attributes(response: "declined")
    end
    Resque.enqueue(App::Background::MemberNotAccepted,params[:user_id] , @pitch.id)
    redirect_to :back
  end
  
  def team
    @pitch = @program.pitches.find(params[:id])
    @users = User.find(@pitch.team)
    render "dashboards/people", layout: "application_new_design"
  end

  def be_member
    @pitch = @program.pitches.find(params[:id])
    @pitch.invite_members(params[:members])
    redirect_to :back
  end

  def invite_mentor
    @pitch = @program.pitches.find(params[:id])
    @pitch.invite_mentor(params[:mentor_id], current_user.id)
    render :json => {:status => "Ok"}
  end

  def shortlist
    @pitch = @program.pitches.find(params[:id])
    if current_user.selector?(@program)
      @pitch.shortlist!(current_user)
    end
    if params[:delete] == "true"
      @pitch.already_shortlist_by(current_user).delete
    end
    redirect_to :back
  end

  def finalist
    @pitch = @program.pitches.find(params[:id])
    if current_user.selector?(@program)
      @pitch.finalists!(current_user)
    end
    if params[:delete] == "true"
      @pitch.already_finalist_by(current_user).delete
    end
    redirect_to :back
  end

  def feeds
    @pitch = @program.pitches.find(params[:id])
    @cm_feeds = CommunityFeed.feed_for_pitch(@pitch.program_id, @pitch.id.to_s, roles_string).page(params[:page])
    @cm_feeds = @cm_feeds.in(tags: params[:tag]) if params[:tag].present?
    @diligence_feeds = DueDiligenceFeed.where(:pitch_id => @pitch.id).order_by(:created_by => "DESC")
    render :layout => "application_new_design"
  end

  def due_diligence
    pitch = @program.pitches.find(params[:id])
    feed = @program.activity_feeds.new(:type=>"due_diligence_post", :user_id => current_user.id, :pitch_id=> pitch.id) if !params[:save] and params[:due_diligence]
    params[:due_diligence].each do |matrix_id, values|
      due_diligence = pitch.pitch_due_diligence_matrices.find_or_initialize_by(panellist_id: current_user.id.to_s, program: @program, matrix_id: matrix_id)
      due_diligence[:points] = values[:points]
      due_diligence[:feedback] = values[:feedback]
      due_diligence.save!
      unless params[:save]
        due_diligence_post = pitch.due_diligence_posts.create!(panellist_id: current_user.id.to_s, program: @program, matrix_id: matrix_id, points: values[:points], feedback: values[:feedback])
        feed[:post_due_diligence_ids] << due_diligence_post.id
      end
      flash[:notice] = "Thank you for submitting your vote"
    end if params[:due_diligence]
    feed.save if !params[:save] and params[:due_diligence]
    redirect_to :back
  end

  def skills_needed
    @pitch = @program.pitches.find(params[:id])
    if params[:do].present?
      @pitch.send("#{params[:do]}_skills!", params[:skill])
    end
    redirect_to :back
  end

  def refer_pitch_some_one
    pitch = @program.pitches.find(params[:id])
    invitation_msg = params[:message]
    from = current_user.id
    mentor_name = params[:user_name]
    mentor_email = params[:email]
    Resque.enqueue(App::Background::PitchReferToPerson, @program.id, pitch.id, mentor_name, mentor_email, invitation_msg, from)
    redirect_to :back,:notice => "Process successful."
  end

  def be_collaborater
    begin
      @pitch = @program.pitches.find(params[:id])
      @pitch.add_to_collaborater_requesters!(current_user)
      @all_team_members = []
      @all_team_members  <<  User.in(:id  => @pitch.members)
      @all_team_members  << @pitch.user
      @collaborater = current_user
      invitation_msg = params[:message]
      @pitch.invitations.where(invitee_id: @pitch.user.id, invitee_type: "collaborator").delete
      @pitch.invitations.create(program_id: @program.id, invited_by_id: current_user.id, invitee_id: @pitch.user.id, invitee_type: "collaborator", status: "pending")
      @pitch.collaborater_requests.create!(request_text: invitation_msg, user_id: current_user.id)
      @pitch.collaborater_offer(@collaborater.id , @pitch.id, @all_team_members.flatten, invitation_msg)
      @program.activity_feeds.create(:type=>"pitch_collaborator", :user_id => current_user.id, :pitch_id=> @pitch.id)
      flash[:notice] = "Collaboration request successfully sent"
      redirect_to :back
    rescue Exception => e
      flash[:notice] = "#{e.message}"
      redirect_to :back
    end
  end

  def add_collaborater_requester
    @pitch = @program.pitches.find(params[:id])
    @pitch.remove_from_collaborater_requesters!(params[:user_id])
    @pitch.add_to_collaboraters!(params[:user_id])
    accepted_by = current_user.id
    #for storing the activity details
    @program.activity_feeds.create(:type=>"pitch_member", :user_id => params[:user_id], :pitch_id=> @pitch.id)
    @pitch.invitations.where(program_id: @program.id, invited_by_id: params[:user_id], invitee_type: "collaborator").delete
    @pitch.collaborater_requests.where(user_id: params[:user_id].to_s).destroy
    feed = @program.activity_feeds.where(type: "pitch_collaborator", user_id: params[:user_id], pitch_id: @pitch.id).first
    if feed
       feed.update_attributes(response: "accepted")
    end
    Resque.enqueue(App::Background::AcceptCollaboraterRequester,@pitch.id , accepted_by, params[:user_id])
    redirect_to :back
  end
  
  def remove_collaborater_requester
    @pitch = @program.pitches.find(params[:id])
    @pitch.remove_from_collaborater_requesters!(params[:user_id])
    @pitch.invitations.where(program_id: @program.id, invited_by_id: params[:user_id], invitee_type: "collaborator").delete
    @pitch.collaborater_requests.where(user_id: params[:user_id].to_s).destroy
    rejected_by = current_user.id
    feed = @program.activity_feeds.where(type: "pitch_collaborator", user_id: params[:user_id], pitch_id: @pitch.id).first
    if feed
       feed.update_attributes(response: "declined")
    end
    Resque.enqueue(App::Background::DeclineCollaboraterRequester,@pitch.id , rejected_by, params[:user_id])
    redirect_to :back
  end

  def change_privacy_of_pitch
    pitch = @program.pitches.find(params[:id])
    pitch.pitch_privacies.find_or_initialize_by(custom_field_id: params[:custom_field_id]).update_attributes(:private => params[:private])
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def recommended_events
    @pitch = Pitch.find(params[:id])
    tasks = @pitch.tasks.where(task_option1: "event")
    events = ProgramEvent.in(id: tasks.map(&:task_option2))
    event_sessions = events.map(&:event_sessions).flatten
    @event_sessions = event_sessions.select{|es| es.date >= Date.today }
    @custom_events = @pitch.custom_events.or(:created_by_id => current_user.id.to_s).or(:attendee => current_user.id.to_s)
    @mark_as_present_events =  EventRecord.or(user_id: current_user.id, :confirmed_at.ne=> nil)
    render layout: "application_new_design"
  end

  def assign_mentor
    params[:pitch][:mentors] = params[:pitch][:mentors].reject!(&:empty?)
    new_mentors = params[:pitch][:mentors]
    @pitch = @program.pitches.find(params[:id])
    @pitch.mentors << params[:pitch][:mentors].map(&:to_s)
    @pitch.mentors = @pitch.mentors.flatten.uniq
    if @pitch.save!
      new_mentors.each do |user|
        Resque.enqueue(App::Background::AssignedMentor, current_user.id, @pitch.id, user)
      end
      flash[:notice] = "Pitch has been updated"
      redirect_to :back
    else
      render :action => :edit
    end
  end

  def gallery_pic_remove
    @pitch = Pitch.find(params[:id])
    @pitch.send(params[:data_custom_field_code]).delete(params[:data_custom_field_value])
    respond_to do |format|
      format.json { render :json => @pitch.save }
    end
  end
  
  private

  def upload_custom_field (params, pitch)
    new_params = params
    custom_fields = Pitch.custom_fields.enabled.for_program(@program).where(element_type: "file_upload")
    custom_fields = custom_fields.for_anchor("pitch")
    custom_fields.each do |c_fields|
      action_dispact = params[(c_fields.code).to_sym]
      unless action_dispact.blank?
        if c_fields.options.blank? || (!c_fields.options.blank? and c_fields.options.include?(action_dispact.original_filename.split('.').try(:last).try(:downcase)))
          file_upload = c_fields.upload_file.find_or_initialize_by(for_class: Pitch, class_id: pitch.id )
          file_upload.update_attributes(:avatar => action_dispact)
          new_params[(c_fields.code).to_sym] = file_upload.try(:avatar).try(:url)
        else
          pitch.errors[:base] << "For Field #{c_fields.code} only #{c_fields.options} file type supported"
        end
      end
    end
    return (new_params.nil? ? {} : new_params)
  end

  def gallery_custom_field (new_params,params, pitch)
    new_params = new_params
    custom_fields = Pitch.custom_fields.enabled.for_program(@program).where(element_type: "gallery")
    custom_fields = custom_fields.for_anchor("pitch")
    custom_fields.each do |c_fields|
      if !params[(c_fields.code).to_sym].blank?
        params[(c_fields.code).to_sym] = params[(c_fields.code).to_sym].collect{|p| p if ["image/png","image/jpg","image/jpeg"].include?(p.content_type)}.compact
        
        action_dispacts = params[(c_fields.code).to_sym]
        unless action_dispacts.blank?
        file_urls = []
          action_dispacts.each do |action_dispact| 
            if c_fields.options.blank? || (!c_fields.options.blank? and c_fields.options.include?(action_dispact.original_filename.split('.').try(:last).try(:downcase)))
              file_upload = c_fields.upload_file.create(for_class: Pitch, class_id: pitch.id )
              file_upload.update_attributes(:avatar => action_dispact)
              file_urls << file_upload.try(:avatar).try(:url)
            else
              pitch.errors[:base] << "For Field #{c_fields.code} only #{c_fields.options} file type supported"
            end
          end
          new_params[(c_fields.code).to_sym] = file_urls
        end  
      end

    end
    return (new_params.nil? ? {} : new_params)
  end

  def load_program
    @program = Program.find(params[:program_id])
  end

end
