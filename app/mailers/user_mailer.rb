class UserMailer < ActionMailer::Base
  include Devise::Mailers::Helpers
  # default from: Devise.mailer_sender

  def invite_user(user, resource, role = nil)
    @user = user
    @resource = resource
    @role = role
    @domain_host = DomainMapping.domain(resource)
    @subject = !!@role ? "You are invited as a #{role}" : "You are invited"
    mail(to: @user.email, subject: @subject, from: "#{@resource.title} <info@apptual.com>")
  end

  def invite_member(user, resource, pitch)
    @user = user
    @resource = resource
    @role = "participant"
    @pitch = Pitch.find(pitch)
    @domain_host = DomainMapping.domain(@pitch.program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    @subject = "You are invited as a member to #{@pitch.title}"
    mail(to: @user.email, subject: @subject, from: "#{@pitch.program.title} <info@apptual.com>")
  end

  def invite_mentor(user, resource, pitch, invitation)
    @user = user
    @resource = resource
    @role = Semantic.t(@resource, 'role_type:mentor')
    @pitch = Pitch.find(pitch)
    @invitation = invitation
    @invited_by = User.find(invitation.invited_by_id)
    @subject = "You are invited as a #{@role} to #{@pitch.title}"
    @domain_host = DomainMapping.domain(@pitch.program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    mail(to: @user.email, subject: @subject, from: "#{@pitch.program.title} <info@apptual.com>")
  end

  def invite_team_member(user, resource, pitch,message,subject)
    @user = user
    @resource = resource
    @role = "participant"
    @pitch = Pitch.find(pitch)
    @message =message
    @domain_host = DomainMapping.domain(@pitch.program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    if subject ==false
      @subject = "You are invited as a member to #{@pitch.title}"
    else
      @subject = subject
    end
    @message =  @message.gsub("#from", !@pitch.user.first_name.nil? ? @pitch.user.first_name : "#from" ).gsub("#to", !@user.first_name.nil? ? @user.first_name : "#to").gsub("#projectname",@pitch.title).gsub("#programname",@resource.title).gsub("#companyname",@pitch.program.organisation.company_name)
    mail(to: @user.email, subject: @subject, from: "#{@pitch.program.title} <info@apptual.com>")
  end

  def invite_team_mentor(user, resource, pitch, invitation, message,subject)
    @user = user
    @resource = resource
    @role = "mentor"
    @pitch = Pitch.find(pitch)
    @invitation = invitation
    @message =message
    @domain_host = DomainMapping.domain(@pitch.program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    if subject ==false
      @subject = "You are invited as a mentor to #{@pitch.title}"
    else
      @subject = subject
    end
    @message =  @message.gsub("#from", !@pitch.user.first_name.nil? ? @pitch.user.first_name : "#from" ).gsub("#to", !@user.first_name.nil? ? @user.first_name : "#to").gsub("#projectname",@pitch.title).gsub("#programname",@resource.title).gsub("#companyname",@pitch.program.organisation.company_name)
    mail(to: @user.email, subject: @subject, from: "#{@pitch.program.title} <info@apptual.com>")
  end

  def message_all_pitch_members(user, feedback_reciever_id, resource, pitch,feedback, subject, feedback_id, presence)
    @user = user
    @resource = resource
    @pitch = pitch
    @program = @pitch.program
    @program_title =@program.title
    @feedback_reciever = User.find(feedback_reciever_id)
    @feedback_mail = PitchFeedback.find(feedback_id)
    @domain_host = DomainMapping.domain(@program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    feedback_mail = @feedback_mail.content
    if presence == false
      @subject = "FeedbackMail"
      @feedback = feedback_mail
    elsif presence == true
      @subject = subject
      @feedback =  feedback.gsub("#from",user.first_name).gsub("#to",@feedback_reciever.first_name).gsub("#projectname",@pitch.title).gsub("#programname",@program_title).gsub("#companyname",@program.organisation.company_name).gsub("#feedback",feedback_mail)
    end
    @presence = presence
    mail(to: @feedback_reciever.email, subject: @subject, from: "#{@program.title} <info@apptual.com>")
  end

  def invite_user_message(user, resource, code, invitation_message, program_invitation_mail_id)
    @user = user
    @resource = resource
    @role = code
    @message_sortcode = invitation_message
    @program_invitation_mail_id = program_invitation_mail_id
    @domain_host = DomainMapping.domain(resource)
    @subject = !!@role ? "You are invited as a #{code}" : "You are invited"
    mail(to: @user.email, subject: @subject, from: "#{@resource.title} <info@apptual.com>")
  end

  def welcome_user_message(user, role, welcome_message, program)
    @program = program
    @user = user
    @role = role
    @welcome_message = welcome_message
    @subject = "Congratulations! Welcome to the #{program.try(:title)}"
    @domain_host = DomainMapping.domain(@program)
    mail(to: @user.email, subject: @subject, from: "#{@program.title} <info@apptual.com>")
  end

  def invite_admin(user, resource, role = nil, invitation_message,subject, invitor_id)
    @user = user
    @admin = User.where(id: resource.owner_id).first
    @resource = resource
    @role = role
    @invitation_message = invitation_message
    invitor = User.where(id: invitor_id).first
    if @subject == false
      @subject = !!@role ? "You are invited as a #{role}" : "You are invited"
    else
      @subject = subject
    end
    @domain_host = DomainMapping.domain(@resource)
    @invitation_message =  @invitation_message.gsub("#from", invitor.try(:first_name)).gsub("#to",!@user.first_name.nil? ? @user.first_name : "#to").gsub("#companyname",@resource.company_name)
    mail(to: @user.email, subject: @subject, from: "#{@resource.company_name} <info@apptual.com>")
  end

  def admin_announcement_mail(member, community_feed, user, program)
    @user = user
    @member = member
    @program = program
    @community_feed = community_feed
    @domain_host = DomainMapping.domain(@program)
    @default_subject = "Admin of #{@program.title} made an announcement"
    @subject = (@community_feed.subject.blank?)?(@default_subject):(@community_feed.subject)
    mail(to: @member.email, subject: @subject, from: "#{@program.title} <info@apptual.com>")
  end

  def reminder_user(user, resource, code, subject,message)
    @user = user
    @resource = resource
    @role = code
    @message = message
    @subject = subject
    @domain_host = DomainMapping.domain(@resource)
    mail(to: @user.email, subject: @subject, from: "#{@resource.title} <info@apptual.com>")
  end

  def mentor_offer_mail(user,resource,pitch,member,message,subject)
    @user =user
    @resource =resource
    @member =member["email"]
    @member_first_name = member["first_name"]
    @pitch = pitch
    @message = message
    @domain_host = DomainMapping.domain(@pitch.program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    @subject =subject
    if @subject == false
      @subject = "Mentor Offer"
    else
      @subject =subject
    end
    if !@message == false
      @message =  @message.gsub("#from", !@user.first_name.nil? ? @user.first_name : "#from" ).gsub("#to", !@member_first_name.nil? ? @member_first_name : "#to").gsub("#projectname",@pitch.title).gsub("#programname",@resource.title).gsub("#companyname",@pitch.program.organisation.company_name)
    end
    mail(to: @member, subject: @subject, from: "#{@pitch.program.title} <info@apptual.com>")
  end

  def join_team_mail(user,resource,pitch,member,message,subject)
    @user =user
    @resource =resource
    @member =member["email"]
    @member_first_name = member["first_name"]
    @pitch = pitch
    @message = message
    @subject =subject
    @domain_host = DomainMapping.domain(@pitch.program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    if @subject == false
      @subject = "I would like to join this team"
    else
      @subject =subject
    end
    if !@message == false
      @message =  @message.gsub("#from", !@user.first_name.nil? ? @user.first_name : "#from" ).gsub("#to", !@member_first_name.nil? ? @member_first_name : "#to").gsub("#projectname",@pitch.title).gsub("#programname",@resource.title).gsub("#companyname",@pitch.program.organisation.company_name)
    end
    mail(to: @member, subject: @subject, from: "#{@pitch.program.title} <info@apptual.com>")
  end

  def submit_project_mail(user,resource,pitch,message,subject)
    @user =user
    @resource =resource
    @pitch = pitch
    @message = message
    if @message == false
      @message = "<div>Dear team #projectname<br></div><div><br></div><div>Thanks a lot for submitting your #projectsemantic.<br></div><div><br></div><div>The jury will soon be voting and we will come back to you as soon as this is done!<br></div><div><br></div><div>#programname<br></div>"
    end
    @subject =subject
    if @subject == false
      @subject = "Thanks for submitting your project!"
    else
      @subject =subject
    end
    all_team_members = []
    all_team_members  <<  User.in(:id => pitch.members)
    all_team_members  <<  User.in(:id  => pitch.mentors)
    all_team_members  << pitch.user
    emails = all_team_members.flatten.map(&:email)
    @message =  @message.gsub("#from", !@user.first_name.nil? ? @user.first_name : "#from" ).gsub("#projectname",@pitch.title).gsub("#programname",@resource.title).gsub("#companyname",@pitch.program.organisation.company_name).gsub("#projectsemantic", Semantic.t(@pitch.program,'pitch'))
    mail(to: [emails], subject: @subject, from: "#{@pitch.program.title} <info@apptual.com>", reply_to: pitch.user.try(:email))
  end

  def rejection_user_message(user, role, program)
    @program = program
    @user = user
    @role = role
    @subject = "Your application to the #{program.try(:title)}"
    mail(to: @user.email, subject: @subject, from: "#{@program.title} <info@apptual.com>")
  end

  def activity_feeds_mail(program_id, user_id, mail_setting)
    @mail_setting = mail_setting == "everyday" ? "today" : "this week"
    @schedule = mail_setting == "everyday" ? 1.day : 7.day
    @program = Program.find(program_id)
    @feeds = CommunityFeed.feed_for_program(@program.id, ["all"]).for_pitch(nil).where(:created_at => (Time.now - @schedule)..Time.now)
    @domain_host = DomainMapping.domain(@program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    @member = User.find(user_id)
    if !@feeds.blank?
      mail(to: @member.email, subject: "Activity Feeds of #{@program.title}", from: "#{@program.title} <info@apptual.com>")
    end
  end

  def project_feeds_mail(pitch_id, user_id, mail_setting)
    @mail_setting = mail_setting == "everyday" ? "today" : "this week"
    @schedule = mail_setting == "everyday" ? 1.day : 7.day
    @pitch = Pitch.where(id: pitch_id).first
    @program = @pitch.program
    @feeds = CommunityFeed.feed_for_pitch(@program.id, @pitch.id, ["all"]).for_pitch(pitch_id).where(:created_at => (Time.now - @schedule)..Time.now)
    @member = User.find(user_id)
    @domain_host = DomainMapping.domain(@program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    if !@feeds.blank?
      mail(to: @member.email, subject: "Project Feeds of #{@pitch.title}", from: "#{@pitch.title} <info@apptual.com>")
    end
  end

  def bug_reporting_message(email, subject, description, organisation)
    @organisation = Organisation.where(id: organisation).first
    @description = description
    mail(to: "bugs@apptual.com", subject: subject, from: email, reply_to: email)
  end

  def ask_questions_message(email, subject, description, organisation)
    @organisation = Organisation.where(id: organisation).first
    @description = description
    admin_emails = User.in(id: @organisation.try(:admins)).map(&:email)
    mail(to: admin_emails, subject: subject, from: email, reply_to: email)
  end

  def message_to_admin(user_id, role, program_id)
    @program = Program.where(id: program_id).first
    program_admins = []
    program_admins << @program.try(:organisation).try(:admins)
    program_admins << @program.try(:organisation).try(:owner).try(:id)
    program_admins = program_admins.flatten.uniq
    admin_emails = User.in(id: program_admins).map(&:email)
    @user = User.where(id: user_id).first
    @role = role
    @domain_host = DomainMapping.domain(@program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    @subject = "A new #{@role} wants to join the program"
    admin_emails.each do |admin|
      mail(to: admin, subject: @subject, from: "#{@program.title} <info@apptual.com>").deliver
    end
  end

  def contact_us(program_id, from, name, subject, body)
    @program = Program.where(id: program_id).first
    @subject = subject
    @body = body
    @name = name
    admin_emails = User.in(id: @program.try(:organisation).try(:admins)).map(&:email)
    mail(to: admin_emails, subject: @subject, reply_to: from, from: from).deliver
  end

  def user_reminder_mail(program_id, user_id, course_setting_id)
    @program = Program.find(program_id)
    @course_setting = CourseSetting.find(course_setting_id)
    @member = User.find(user_id)
    t = @course_setting.inactive_user.to_i
    inactive_duration = t == 1.day ? "1 day" : ( t == 2.days ? "2 days" : ( t == 3.days ? "3 days" : "1 week"))
    mail(to: @member.email, subject: "Inactive from more than #{inactive_duration} for #{@program.title}", from: "#{@program.title} <info@apptual.com>")
  end

  def refer_pitch_to_person(program_id, pitch_id, mentor_name, mentor_email, invitation_msg, from)
    @program = Program.where(id: program_id).first
    @pitch = Program.where(id: program_id).first.pitches.where(id: pitch_id).first
    @mentor_name = mentor_name
    @invitation_msg = invitation_msg
    @from = User.where(id: from).first
    @mentor_email = mentor_email
    @domain_host = DomainMapping.domain(@program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    mail(to: mentor_email, subject: "#{@from.first_name} #{@from.last_name} is inviting you to join #{@program.title} as a #{Semantic.t(@program, 'role_type:mentor')} for #{@program.title}", from: "#{@program.title} <info@apptual.com>", reply_to: @from.try(:email)).deliver
  end

  def collaboration_request(user_id, pitch_id, member, invitation_msg)
    @pitch = Pitch.where(id: pitch_id).first
    @program = @pitch.program
    @invitation_msg = invitation_msg
    @from = User.where(id: user_id).first
    @domain_host = DomainMapping.domain(@program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    @member = member
    mail(to: @member["email"], subject: "Collaboration request from #{@from.try(:first_name).try(:titleize)} #{@from.try(:last_name).try(:titleize)}", from: "#{@program.title} <info@apptual.com>", reply_to: @from.try(:email)).deliver
  end

  def accept_collaboration_request(pitch_id, accepted_by, user_id)
    @pitch = Pitch.where(id: pitch_id).first
    @program = @pitch.program
    @from = User.where(id: accepted_by).first
    @user= User.where(id: user_id).first
    @domain_host = DomainMapping.domain(@program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    mail(to: [@user.email, @from.try(:email)], subject: "Collaboration request accepted: #{@user.try(:first_name).try(:titleize)} meet #{@from.try(:first_name).try(:titleize)}", from: "#{@program.title} <info@apptual.com>").deliver
  end

  def accept_collaboration_request_cc(pitch, accepted_by, user, resource, message, subject)
    @pitch = pitch
    @program = resource
    @from = User.where(id: accepted_by).first
    @user= user
    @message = message
    @subject =subject
    @domain_host = DomainMapping.domain(@program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    if @subject == false
      @subject = "Collaboration request accepted: #{@user.try(:first_name).try(:titleize)} meet #{@from.try(:first_name).try(:titleize)}"
    else
      @subject =subject.gsub("#xxx", @user.try(:first_name).try(:titleize)).gsub("#yyy", @from.try(:first_name).try(:titleize))
    end
    if !@message == false
      @message =  @message.gsub("#from", !@user.first_name.nil? ? @user.first_name : "#from" ).gsub("#to", !@member_first_name.nil? ? @member_first_name : "#to").gsub("#projectname",@pitch.title).gsub("#programname",@program.title).gsub("#companyname",@pitch.program.organisation.company_name)
    end
    all_team_members = []
    all_team_members  <<  User.in(:id => @pitch.members)
    #all_team_members  << @pitch.user
    emails = all_team_members.flatten.map(&:email)
    mail(to: [@user.try(:email), @from.try(:email)], cc: emails, subject: @subject, from: "#{@program.title} <info@apptual.com>").deliver
  end

  def reject_collaboration_request(pitch_id, rejected_by, user_id)
    @pitch = Pitch.where(id: pitch_id).first
    @program = @pitch.program
    @from = User.where(id: rejected_by).first
    @user= User.where(id: user_id).first
    mail(to: @user.email, subject: "Collaboration request declined", from: "#{@program.title} <info@apptual.com>", reply_to: @from.try(:email)).deliver
  end

  def send_contact_request(request_id)
    request = UserContactRequest.where(id: request_id).first
    @requester = request.try(:requester)
    @receiver = User.where(id: request.try(:receiver_id)).first
    @message = request.try(:message)
    @program = request.try(:program)
    @domain_host = DomainMapping.domain(@program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    mail(to: @receiver.email, subject: "You have a message from #{@requester.try(:full_name)}: #{request.try(:subject)}", from: @requester.email, reply_to: @requester.email)
  end

  def send_welcome_message_to_admin(user_id, org_id)
    @user = User.where(id: user_id).first
    @organisation = Organisation.where(id: org_id).first
    mail(to: @user.try(:email), bcc: "getintouch@apptual.com", subject: "Thanks for choosing Apptual", from: "info@apptual.com")
  end

  def send_approval_message_to_admin(user_id, org_id)
    @user = User.where(id: user_id).first
    @organisation = Organisation.where(id: org_id).first
    mail(to: @user.try(:email), subject: "Welcome to Apptual", from: "info@apptual.com")
  end

  def organisation_contact_us(organisation_id, from, name, subject, body)
    @organisation = Organisation.where(id: organisation_id).first
    @subject = subject
    @body = body
    @name = name
    admin_emails = User.in(id: @organisation.try(:admins)).map(&:email)
    mail(to: admin_emails, subject: @subject, reply_to: from, from: from).deliver
  end

  def send_invite_mentor_response(pitch_id, mentor_id, response, resource)
    @pitch = Pitch.find_by(id: pitch_id)
    @mentor = User.find_by(id: mentor_id)
    @response = response
    @resource = resource
    @subject = response == "Accepted" ? "Mentor request accepted" : "Declines mentor request"
    @domain_host = DomainMapping.domain(@pitch.program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    team_emails = User.in(id: @pitch.team).map(&:email)
    mail(to: team_emails, subject: @subject, from: "#{@pitch.program.title} <info@apptual.com>").deliver
  end

  def send_mentor_offer_response(pitch_id, mentor_id, response, resource)
    @pitch = Pitch.find_by(id: pitch_id)
    @mentor = User.find_by(id: mentor_id)
    @response = response
    @resource = resource
    @subject = response == "Added" ? "Mentor request accepted" : "Mentor request declined"
    @domain_host = DomainMapping.domain(@pitch.program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    mail(to: @mentor.email, subject: @subject, from: "#{@pitch.program.title} <info@apptual.com>").deliver
  end

  def voting_sheet_request(user_id, prog_id, folder_name)
    @user = User.find_by(id: user_id)
    @program = Program.find_by(id: prog_id)
    @subject = "Request for Voting Sheet"
    attachments["#{@program.title}.zip"] = {:body => File.read("#{Rails.root.to_s}/tmp/#{folder_name}.zip")}
    mail(to: @user.email, subject: @subject, from: "#{@program.title} <info@apptual.com>").deliver
    #File.chmod(0755,"#{Rails.root.to_s}/tmp/#{folder_name}.zip")
    FileUtils.rm_rf(Dir.glob("#{Rails.root.to_s}/tmp/#{folder_name}.zip"))
  end

  def send_survey_mail(survey_id,user_id)
    @survey = Survey.where(:id => survey_id).first
    @requester = user_id ? User.where(:id => user_id).first : @survey.user
    @program = @survey.program
    @domain_host = DomainMapping.domain(@program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    @subject = @survey.subject
    user_ids = @survey.total_audience
    user_ids.each do |u|
      @user = User.where(:id => u).first
      mail(to: @user.email , subject: @subject, from: "#{@program.title} <info@apptual.com>").deliver
    end
  end

  def send_survey_message_mail(survey_id, user_ids, requester, subject, message)
    @survey = Survey.where(:id => survey_id).first
    @requester = User.where(:id => requester).first
    @program = @survey.program
    @subject = subject
    @message = message
    user_ids.each do |u|
      @user = User.where(:id => u).first
      mail(to: @user.email , subject: @subject, from: "#{@program.title} <info@apptual.com>").deliver
    end
  end

  def send_participant_rejection_mail(event_record_id, subject, message)
    event_record = EventRecord.where(id: event_record_id).first
    @user = event_record.try(:user)
    @message = message
    @program = event_record.try(:program)
    mail(to: @user.email, subject: subject, from: "#{@program.try(:title)} <info@apptual.com>")
  end

  def message_all_participant_event(user_id, event_session_id, subject, message)
    event_session = EventSession.where(id: event_session_id).first
    @user = User.where(id: user_id).first
    @message = message
    @program = event_session.try(:program_event).try(:program)
    mail(to: @user.email, subject: subject, from: "#{@program.try(:title)} <info@apptual.com>")
  end

  def immediate_post_mail(member, community_feed, user, program, pitch)
    @pitch = pitch if pitch.present?
    @user = user
    @member = member
    @program = program
    @community_feed = community_feed
    @domain_host = DomainMapping.domain(@program)
    @default_subject = "#{@user.first_name} shared a post on #{@pitch.blank? ? @program.try(:title) : @pitch.try(:title)}"
    @subject = (@community_feed.subject.blank?)?(@default_subject):(@community_feed.subject)
    mail(to: @member.email, subject: @subject, from: "#{@pitch.blank? ? @program.try(:title) : @pitch.try(:title)} <info@apptual.com>" )
  end

  def registered_for_event(user, event_session)
    @user = user
    @event_session = event_session
    @program = @event_session.program_event.program
    @subject = "Thanks for registering to #{event_session.program_event.try(:title)}"
    mail(to: @user.email, subject: @subject, from: "#{@program.try(:title)} <info@apptual.com>" )
  end

  def event_full(user, event_session)
    @user = user
    @event_session = event_session
    @program = @event_session.program_event.program
    @subject = "You are on the waiting list for #{event_session.program_event.try(:title)}"
    mail(to: @user.email, subject: @subject, from: "#{@program.try(:title)} <info@apptual.com>" )
  end

  def events_reminder(user, event_session)
    @user = user
    @event_session = event_session
    @program = @event_session.program_event.program
    @subject = " Reminder #{event_session.program_event.try(:title)} will take place tomorrow"
    mail(to: @user.email, subject: @subject, from: "#{@program.try(:title)} <info@apptual.com>" )
  end

  def assigned_mentor(admin, pitch, user)
    @user = user
    @admin = admin
    @pitch = pitch
    @program = @pitch.program
    @mentor_semantic = Semantic.translate(@program, "role_type:mentor")
    @subject = " #{@admin.first_name} wants you to be #{@mentor_semantic} for #{@pitch.try(:title)}"
    mail(to: @user.email, subject: @subject, from: "#{@program.try(:title)} <info@apptual.com>" )
  end
  
  def member_joined_team(user,resource,pitch,message,subject)
    @user =user
    @resource =resource
    @pitch = pitch
    @message = message
    @subject =subject
    @domain_host = DomainMapping.domain(@pitch.program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    if @subject == false
      @subject = "Your demand to join team #{@pitch.try(:title)} has been accepted"
    else
      @subject =subject.gsub("#to", !@user.first_name.nil? ? @user.first_name : "#to" ).gsub("#projectname",@pitch.title).gsub("#programname",@resource.title).gsub("#companyname",@pitch.program.organisation.company_name)
    end
    if !@message == false
      @message =  @message.gsub("#to", !@user.first_name.nil? ? @user.first_name : "#to" ).gsub("#projectname",@pitch.title).gsub("#programname",@resource.title).gsub("#companyname",@pitch.program.organisation.company_name)
    end
    mail(to: @user.email, subject: @subject, from: "#{@pitch.program.title} <info@apptual.com>")
  end

  def member_not_accepted(user,resource,pitch,message,subject)
    @user =user
    @resource =resource
    @pitch = pitch
    @message = message
    @subject =subject
    @domain_host = DomainMapping.domain(@pitch.program)
    @sub_domain = DomainMapping.sub_domain?(@domain_host)
    if @subject == false
      @subject = "Your demand to join team #{@pitch.try(:title)} has been Rejected"
    else
      @subject =subject.gsub("#to", !@user.first_name.nil? ? @user.first_name : "#to" ).gsub("#projectname",@pitch.title).gsub("#programname",@resource.title).gsub("#companyname",@pitch.program.organisation.company_name)
    end
    if !@message == false
      @message =  @message.gsub("#to", !@user.first_name.nil? ? @user.first_name : "#to" ).gsub("#projectname",@pitch.title).gsub("#programname",@resource.title).gsub("#companyname",@pitch.program.organisation.company_name)
    end
    mail(to: @user.email, subject: @subject, from: "#{@pitch.program.title} <info@apptual.com>")
  end

  def send_report(user, report, prog_id)
    @user=user
    @program= Program.find(prog_id)
    @organisation = @program.try(:organisation)
    @report=report
    @subject="Report file is attached"    
    attachments['report.pdf'] = {:body => File.read("#{Rails.root.to_s}/tmp/#{Reporting.generate_report(@report, @program, @organisation)}")}
    mail(to: @user.email, subject: @subject, from: "info@apptual.com")
  end
  
  def rate_event_session(user, event_session, resource, message, subject)
    @user = user
    @event_session = event_session
    @program = resource
    @message = message
    @subject =subject
    if @subject == false
      @subject = "Rate event mail for #{event_session.program_event.try(:title)}"
    else
      @subject =subject.gsub("#to_fname", !@user.first_name.nil? ? @user.first_name : "#to" ).gsub("#to_lname", !@user.last_name.nil? ? @user.last_name : "#to" ).gsub("#eventname", event_session.program_event.try(:title)).gsub("#eventdate",event_session.try(:date).to_s)
    end
    if !@message == false
      @message =  @message.gsub("#to_fname", !@user.first_name.nil? ? @user.first_name : "#to" ).gsub("#to_lname", !@user.last_name.nil? ? @user.last_name : "#to" ).gsub("#eventname", event_session.program_event.try(:title)).gsub("#eventdate",event_session.try(:date).to_s)
    end
    @tokens = Token.where(event_session_id: @event_session.id, user_id: @user.id, expires_at: nil)
    mail(to: @user.email, subject: @subject, from: "#{@program.try(:title)} <info@apptual.com>" )
  end
end