module App
  module Background
    class InvitationMailer

      @queue = :background_mailer

      def self.perform(user_id, resource_id, resource_type, code)
        user = ::User.find(user_id)
        resource = resource_type.constantize.find(resource_id)
        ::UserMailer.invite_user(user, resource, code).deliver
      end
    end

    class RequestVotingSheet
      @queue = :voting_sheet

      def self.perform(user_id, prog_id, option, pitch_id)
        folder_name = App::Pdf::GenrateVotingSheet.generate_files(prog_id, option, pitch_id)
        App::ZipFolder::CreateZip.create_zip_pdf(folder_name, pitch_id, prog_id, option)
        ::UserMailer.voting_sheet_request(user_id, prog_id, folder_name)
      end
    end

    class InviteMemberByAdmin
      @queue = :background_mailer

      def self.perform(user_id, resource_id, resource_type, code, invitation_message, program_invitation_mail_id)
        user = ::User.find(user_id)
        resource = resource_type.constantize.find(resource_id)
        ::UserMailer.invite_user_message(user, resource, code, invitation_message, program_invitation_mail_id).deliver
      end
    end

    class InvitationMailerToAdmin
      @queue = :background_mailer
      def self.perform(user_id, resource_id, resource_type, code, invitation_message, invitor_id)
        user = ::User.find(user_id)
        resource = resource_type.constantize.find(resource_id)
        if resource.programs.collect(&:customize_admin_emails).flatten.present? && resource.programs.collect(&:customize_admin_emails).flatten.collect{|p| p  if p.email_name == "admin_invite"}.compact.first.present?
          message = resource.programs.collect(&:customize_admin_emails).flatten.collect{|p| p  if p.email_name == "admin_invite"}.compact.first.description
          subject = resource.programs.collect(&:customize_admin_emails).flatten.collect{|p| p  if p.email_name == "admin_invite"}.compact.first.subject
         ::UserMailer.invite_admin(user, resource, code, message,subject, invitor_id).deliver
        elsif CustomizeAdminEmail.where(:email_name => "admin_invite", :role_type => "super_admin").present?
          message = CustomizeAdminEmail.where(:email_name => "admin_invite", :role_type => "super_admin").first.description
          subject = CustomizeAdminEmail.where(:email_name => "admin_invite", :role_type => "super_admin").first.subject
         ::UserMailer.invite_admin(user, resource, code, message,subject, invitor_id).deliver
        else
          subject = false
          ::UserMailer.invite_admin(user, resource, code, invitation_message,subject, invitor_id).deliver
        end
      end
    end

    class WelcomMessageMail
      @queue = :background_mailer
     def self.perform(user_id, role, welcome_message, program_id)
        user = ::User.find(user_id)
        program = ::Program.find(program_id)
        ::UserMailer.welcome_user_message(user, role, welcome_message, program).deliver
      end
    end

    class RejectionMessageMail
      @queue = :background_mailer
     def self.perform(user_id, role, program_id)
        user = ::User.find(user_id)
        program = ::Program.find(program_id)
        ::UserMailer.rejection_user_message(user, role, program).deliver
      end
    end

    class BugReportingMail
      @queue = :background_mailer
     def self.perform(email, subject, description, organisation)
        ::UserMailer.bug_reporting_message(email, subject, description, organisation).deliver
      end
    end

    class AskQuestionsMail
      @queue = :background_mailer
     def self.perform(email, subject, description, organisation)
        ::UserMailer.ask_questions_message(email, subject, description, organisation).deliver
      end
    end

    class MessageToAdmin
      @queue = :background_mailer
     def self.perform(user_id, role, program_id)
        ::UserMailer.message_to_admin(user_id, role, program_id)
      end
    end

    class ProgramContactUs
      @queue = :background_mailer
     def self.perform(program_id, from, name, subject, body)
        ::UserMailer.contact_us(program_id, from, name, subject, body)
      end
    end

    class PitchReferToPerson
      @queue = :background_mailer
      def self.perform(program_id, pitch_id, mentor_name, mentor_email, invitation_msg, from)
          ::UserMailer.refer_pitch_to_person(program_id, pitch_id, mentor_name, mentor_email, invitation_msg, from)
      end
    end

    class AdminAnnouncementMailer
      @queue = :background_mailer

      def self.perform(member_id, community_feed_id, user_id, program_id)
          user = ::User.find(user_id)
          member = ::User.find(member_id)
          program = ::Program.find(program_id)
          community_feed = ::CommunityFeed.find(community_feed_id)
          ::UserMailer.admin_announcement_mail(member, community_feed, user, program).deliver
      end
    end

    class MessageMailer
      @queue = :background_mailer

      def self.perform(emails, subject, body, organisation_id)
        organisation = ::Organisation.find(organisation_id)
        ::MessageMailer.message_all(emails, subject, body, organisation)
      end
    end

    class UserAdoption
      @queue = :background_mailer

      def self.perform(method, *args)
        ::UserAdoptionMailer.send(method.to_sym, *args).deliver
      end
    end

    class CommunityFeedMailer
      @queue = :background_mailer

      def self.perform(method, *args)
        ::CommunityFeedMailer.send(method.to_sym, *args).deliver
      end
    end

    class ActivityFeedsMail
      @queue = :background_mailer

      def self.perform(program_id, user_id, mail_setting)
        ::UserMailer.activity_feeds_mail(program_id, user_id, mail_setting).deliver
      end
    end

    class ProjectFeedsMail
      @queue = :background_mailer

      def self.perform(pitch_id, user_id, mail_setting)
        ::UserMailer.project_feeds_mail(pitch_id, user_id, mail_setting).deliver
      end
    end

    class CollaborationOfferMailer
       @queue = :background_mailer
      def self.perform(user_id,pitch_id,member, invitation_msg) 
         ::UserMailer.collaboration_request(user_id, pitch_id, member, invitation_msg)
      end
    end

    class AcceptCollaboraterRequester
       @queue = :background_mailer
      def self.perform(pitch_id, accepted_by, user_id) 
         #::UserMailer.accept_collaboration_request(pitch_id, accepted_by, user_id)
         user = ::User.find(user_id)
         pitch = Pitch.find(pitch_id)
         resource =pitch.program
          if resource.customize_admin_emails.where(:email_name => "collaboration_successfull").present?
            customize_admin_emails = resource.customize_admin_emails.where(:email_name => "collaboration_successfull").first.description
            customize_admin_emails_subject = resource.customize_admin_emails.where(:email_name => "collaboration_successfull").first.subject
             if customize_admin_emails_subject.nil?
                customize_admin_emails_subject = false
             end
             ::UserMailer.accept_collaboration_request_cc(pitch, accepted_by, user, resource, customize_admin_emails, customize_admin_emails_subject).deliver
          elsif CustomizeAdminEmail.where(:email_name => "collaboration_successfull", :role_type => "super_admin").present?
            customize_admin_emails = CustomizeAdminEmail.where(:email_name => "collaboration_successfull", :role_type => "super_admin").first.description
            customize_admin_emails_subject = CustomizeAdminEmail.where(:email_name => "collaboration_successfull", :role_type => "super_admin").first.subject
             if customize_admin_emails_subject.nil?
              customize_admin_emails_subject = false
             end
             ::UserMailer.accept_collaboration_request_cc(pitch, accepted_by, user, resource, customize_admin_emails, customize_admin_emails_subject).deliver
          else
            customize_admin_emails = false
            subject =false
            ::UserMailer.accept_collaboration_request_cc(pitch, accepted_by, user, resource, customize_admin_emails, subject).deliver
           
        end
      end
    end

    class DeclineCollaboraterRequester
       @queue = :background_mailer
      def self.perform(pitch_id, rejected_by, user_id) 
         ::UserMailer.reject_collaboration_request(pitch_id, rejected_by, user_id)
      end
    end

    class InviteMember
      @queue = :background_mailer

      def self.perform(user_id, resource_id, resource_type, pitch_id)
        user = ::User.find(user_id)
        resource = resource_type.constantize.find(resource_id)
        pitch = Pitch.find(pitch_id)
          if resource.customize_admin_emails.where(:email_name => "team_member_invite").present?
            customize_admin_emails = resource.customize_admin_emails.where(:email_name => "team_member_invite").first.description
            customize_admin_emails_subject = resource.customize_admin_emails.where(:email_name => "team_member_invite").first.subject
            if customize_admin_emails_subject.nil?
               customize_admin_emails_subject = false
            end
            ::UserMailer.invite_team_member(user, resource, pitch,customize_admin_emails,customize_admin_emails_subject).deliver
          elsif CustomizeAdminEmail.where(:email_name => "team_member_invite", :role_type => "super_admin").present?
            customize_admin_emails = CustomizeAdminEmail.where(:email_name => "team_member_invite", :role_type => "super_admin").first.description
            customize_admin_emails_subject = CustomizeAdminEmail.where(:email_name => "team_member_invite", :role_type => "super_admin").first.subject
            if customize_admin_emails_subject.nil?
              customize_admin_emails_subject = false
            end
            ::UserMailer.invite_team_member(user, resource, pitch,customize_admin_emails,customize_admin_emails_subject).deliver
          else

            ::UserMailer.invite_member(user, resource, pitch).deliver
        end
      end
    end

    class InviteMentor
      @queue = :background_mailer

      def self.perform(user_id, resource_id, resource_type, pitch_id, invitation_id)
        user = ::User.find(user_id)
        resource = resource_type.constantize.find(resource_id)
        pitch = Pitch.find(pitch_id)
        invitation = PitchInvitation.find(invitation_id)
          if resource.customize_admin_emails.where(:email_name => "team_mentor_invite").present?
            customize_admin_emails = resource.customize_admin_emails.where(:email_name => "team_mentor_invite").first.description
            customize_admin_emails_subject = resource.customize_admin_emails.where(:email_name => "team_mentor_invite").first.subject
            if customize_admin_emails_subject.nil?
               customize_admin_emails_subject = false
            end
            ::UserMailer.invite_team_mentor(user, resource, pitch, invitation, customize_admin_emails,customize_admin_emails_subject).deliver
          elsif CustomizeAdminEmail.where(:email_name => "team_mentor_invite", :role_type => "super_admin").present?
            customize_admin_emails = CustomizeAdminEmail.where(:email_name => "team_mentor_invite", :role_type => "super_admin").first.description
            customize_admin_emails_subject = CustomizeAdminEmail.where(:email_name => "team_mentor_invite", :role_type => "super_admin").first.subject
            if customize_admin_emails_subject.nil?
              customize_admin_emails_subject = false
            end
            ::UserMailer.invite_team_mentor(user, resource, pitch, invitation, customize_admin_emails,customize_admin_emails_subject).deliver
          else

            ::UserMailer.invite_mentor(user, resource, pitch, invitation).deliver
        end
      end
    end

    class SubmitProject
       @queue = :background_mailer
      def self.perform(user_id,pitch_id)
         user = ::User.find(user_id)
         pitch = Pitch.find(pitch_id)
         resource =pitch.program
          if resource.customize_admin_emails.where(:email_name => "submit_pitch").present?
            customize_admin_emails = resource.customize_admin_emails.where(:email_name => "submit_pitch").first.description
            customize_admin_emails_subject = resource.customize_admin_emails.where(:email_name => "submit_pitch").first.subject
             if customize_admin_emails_subject.nil?
              customize_admin_emails_subject = false
             end
             ::UserMailer.submit_project_mail(user, resource, pitch,customize_admin_emails, customize_admin_emails_subject).deliver
          elsif CustomizeAdminEmail.where(:email_name => "submit_pitch", :role_type => "super_admin").present?
            customize_admin_emails = CustomizeAdminEmail.where(:email_name => "submit_pitch", :role_type => "super_admin").first.description
            customize_admin_emails_subject = CustomizeAdminEmail.where(:email_name => "submit_pitch", :role_type => "super_admin").first.subject
             if customize_admin_emails_subject.nil?
               customize_admin_emails_subject = false
             end
             ::UserMailer.submit_project_mail(user, resource, pitch,customize_admin_emails, customize_admin_emails_subject).deliver
          else
            customize_admin_emails = false
            subject =false
            ::UserMailer.submit_project_mail(user, resource, pitch,customize_admin_emails, subject).deliver
           
        end
      end
    end

    class RejectParticipant
      @queue = :background_mailer
      def self.perform(event_record, subject, message)
         ::UserMailer.send_participant_rejection_mail(event_record, subject, message).deliver
      end
    end

    class MessageAllParticipant
      @queue = :background_mailer
      def self.perform(event_session_id, subject, message)
        event_session = EventSession.where(id: event_session_id).first
        event_session.event_records.selected.map(&:user_id).each do |user_id|
          ::UserMailer.message_all_participant_event(user_id, event_session_id, subject, message).deliver
        end
      end
    end

    class SendContactRequest
      @queue = :background_mailer
      def self.perform(contact_request)
         ::UserMailer.send_contact_request(contact_request).deliver
      end
    end

    class SendWelcomeMessageToAdmin
      @queue = :background_mailer
      def self.perform(user_id, org_id)
         ::UserMailer.send_welcome_message_to_admin(user_id, org_id).deliver
      end
    end

    class SendApprovalMessageToAdmin
      @queue = :background_mailer
      def self.perform(user_id, org_id)
         ::UserMailer.send_approval_message_to_admin(user_id, org_id).deliver
      end
    end

    class FeedBackMail
      @queue = :background_mailer
       def self.perform(feedback_user_id, feedback_reciever_id, resource_id, resource_type, pitch_id,feedback_id)
        user = User.find(feedback_user_id)
        resource = resource_type.constantize.find(resource_id)
        if resource.customize_admin_emails.where(:email_name => "feedback").present?
          @customize_admin_emails = resource.customize_admin_emails
          feedback(nil,resource,user)
        elsif CustomizeAdminEmail.where(:email_name => "feedback", :role_type => "super_admin").present?
          @customize_admin_emails = CustomizeAdminEmail
          feedback("super_admin",resource,user)
        else
          @presence =false
        end
        pitch = Pitch.find(pitch_id)
          ::UserMailer.message_all_pitch_members(user, feedback_reciever_id, resource, pitch,@feedback, @subject, feedback_id,@presence ).deliver
      end

      private
        def self.feedback(role_type,resource,user)
          if user.role?("company_admin",resource.organisation.id)
            customize_admin_emails("admin")                 
          elsif user.role?("participant",resource.id)
            customize_admin_emails("participant")
          elsif user.role?("selector",resource.id)
            customize_admin_emails("selector")
          elsif user.role?("mentor",resource.id)
            customize_admin_emails("mentor")
          elsif user.role?("panellist",resource.id)
            customize_admin_emails("panel")
          end
          @feedback = @email
          @subject = @subject
          @presence =true
        end
        
        def self.customize_admin_emails(role_type)
          if @customize_admin_emails.where(:from => role_type, :email_name => "feedback", :role_type => role_type).first.present?
            @email  = @customize_admin_emails.where(:from => role_type, :email_name => "feedback", :role_type => role_type).first.description
            @subject  = @customize_admin_emails.where(:from => role_type, :email_name => "feedback", :role_type => role_type).first.subject
          end
        end
    end
     class ReminderUser
      @queue = :background_mailer

      def self.perform(user_id, resource_id, resource_type, code, subject, message)
        user = ::User.find(user_id)
        resource = resource_type.constantize.find(resource_id)
        ::UserMailer.reminder_user(user, resource, code, subject, message).deliver
      end
    end
    class MentorOfferMailer
       @queue = :background_mailer
      def self.perform(user_id,pitch_id,member)
         user = ::User.find(user_id)
         pitch = Pitch.find(pitch_id)
         resource =pitch.program
          if resource.customize_admin_emails.where(:email_name => "mentor_offer").present?
            customize_admin_emails = resource.customize_admin_emails.where(:email_name => "mentor_offer").first.description
            customize_admin_emails_subject = resource.customize_admin_emails.where(:email_name => "mentor_offer").first.subject
             if customize_admin_emails_subject.nil?
               customize_admin_emails_subject = false
             end
             ::UserMailer.mentor_offer_mail(user, resource, pitch, member,customize_admin_emails, customize_admin_emails_subject).deliver
          elsif CustomizeAdminEmail.where(:email_name => "mentor_offer", :role_type => "super_admin").present?
            customize_admin_emails = CustomizeAdminEmail.where(:email_name => "mentor_offer", :role_type => "super_admin").first.description
            customize_admin_emails_subject = CustomizeAdminEmail.where(:email_name => "mentor_offer", :role_type => "super_admin").first.subject
             if customize_admin_emails_subject.nil?
               customize_admin_emails_subject = false
             end
             ::UserMailer.mentor_offer_mail(user, resource, pitch, member,customize_admin_emails, customize_admin_emails_subject).deliver
          else
            customize_admin_emails = false
            subject =false
            ::UserMailer.mentor_offer_mail(user, resource, pitch, member,customize_admin_emails, subject).deliver
           
        end
      end
    end
    class JoinTeamMailer
       @queue = :background_mailer
      def self.perform(user_id,pitch_id,member)
         user = ::User.find(user_id)
         pitch = Pitch.find(pitch_id)
         resource =pitch.program
          if resource.customize_admin_emails.where(:email_name => "join_team").present?
            customize_admin_emails = resource.customize_admin_emails.where(:email_name => "join_team").first.description
            customize_admin_emails_subject = resource.customize_admin_emails.where(:email_name => "join_team").first.subject
             if customize_admin_emails_subject.nil?
               customize_admin_emails_subject = false
             end
             ::UserMailer.join_team_mail(user, resource, pitch, member,customize_admin_emails, customize_admin_emails_subject).deliver
          elsif CustomizeAdminEmail.where(:email_name => "join_team", :role_type => "super_admin").present?
            customize_admin_emails = CustomizeAdminEmail.where(:email_name => "join_team", :role_type => "super_admin").first.description
            customize_admin_emails_subject = CustomizeAdminEmail.where(:email_name => "join_team", :role_type => "super_admin").first.subject
             if customize_admin_emails_subject.nil?
               customize_admin_emails_subject = false
             end
             ::UserMailer.join_team_mail(user, resource, pitch, member,customize_admin_emails, customize_admin_emails_subject).deliver
          else
            customize_admin_emails = false
            subject =false
            ::UserMailer.join_team_mail(user, resource, pitch, member,customize_admin_emails, subject).deliver
           
        end
      end
    end
    class InactiveUserMail
      @queue = :background_mailer
      def self.perform(program_id, user_id, course_id)
        ::UserMailer.user_reminder_mail(program_id, user_id, course_id).deliver
      end
    end
    class OrganisationContactUs
      @queue = :background_mailer
     def self.perform(organisation_id, from, name, subject, body)
        ::UserMailer.organisation_contact_us(organisation_id, from, name, subject, body)
      end
    end
    
    class InviteMentorResponse
      @queue = :background_mailer
      def self.perform(pitch_id, mentor_id, response, resource_id, resource_type)
        resource = resource_type.constantize.find(resource_id)
         ::UserMailer.send_invite_mentor_response(pitch_id, mentor_id, response, resource).deliver
      end
    end
    
    class MentorOfferResponse
      @queue = :background_mailer
      def self.perform(pitch_id, mentor_id, response, resource_id, resource_type)
        resource = resource_type.constantize.find(resource_id)
        ::UserMailer.send_mentor_offer_response(pitch_id, mentor_id, response, resource).deliver
      end
    end
    
    class SurveyMail
      @queue = :survey_mail
      def self.perform(survey_id,user_id = nil)
        ::UserMailer.send_survey_mail(survey_id,user_id)
      end
    end

    class SurveyMessageMail
      @queue = :survey_message_mail
      def self.perform(survey_id, user_ids, requester, subject, message)
        ::UserMailer.send_survey_message_mail(survey_id, user_ids, requester, subject, message)
      end
    end

    class ScheduledUserAdoptionMail
      @queue = :background_mailer
      def self.perform(program_id)
        program = Program.find(program_id)
        setting = MailSetting.find_or_create_by(program: program)
        program.pitches.each do |pitch|
          setting.trigger_iterations(pitch)
          setting.trigger_feedback(pitch)
          setting.trigger_problems(pitch)
          setting.trigger_learnings(pitch)
          setting.trigger_pitch_fields(pitch)
          setting.trigger_project_update(pitch)
        end
      end
    end    

    class ScheduledActivityFeedMail
      @queue = :background_mailer
      def self.perform(program_id)
        program = Program.find(program_id)
        mail_setting = MailSetting.where(:program_id => program.id).first
        if mail_setting.try(:activity_feeds) == "everyday"
          ActivityFeed.activity_feed_mail(program,"everyday")
        end
      end
    end    

    class ScheduledActivityFeedMailWeekly
      @queue = :background_mailer
      def self.perform(program_id)
        program = Program.find(program_id)
        mail_setting = MailSetting.where(:program_id => program.id).first
        if mail_setting.try(:activity_feeds) == "weekly" || mail_setting.blank?
          ActivityFeed.activity_feed_mail(program,"weekly")
        end
      end
    end

    class ScheduledProjectFeedMail
      @queue = :background_mailer
      def self.perform(program_id)
        program = Program.find(program_id)
        mail_setting = MailSetting.where(:program_id => program.id).first
        program.try(:pitches).each do |pitch|
          if mail_setting.try(:feed_day) == "everyday"
            ActivityFeed.project_feed_mail(pitch,"everyday")
          end
        end
      end  
    end    

    class ScheduledProjectFeedMailWeekly
      @queue = :background_mailer
      def self.perform(program_id)
        program = Program.find(program_id)
        mail_setting = MailSetting.where(:program_id => program.id).first
        program.try(:pitches).each do |pitch|
          if mail_setting.try(:feed_day) == "weekly" || mail_setting.blank?
            ActivityFeed.project_feed_mail(pitch,"weekly")
          end
        end
      end  
    end


    class ScheduledInactiveUsersMail
      @queue = :background_mailer
      def self.perform(program_id)
        program = Program.find(program_id)
        if !program.course_setting.blank? && program.try(:course_setting).try(:automated_inactive_email)
          CourseSetting.user_reminder_mail(program, program.course_setting)
        end
      end
    end

    class ImmediatePostMailer
    @queue = :background_mailer

      def self.perform(member_id, community_feed_id, user_id, program_id, pitch_id)
          pitch = ::Pitch.find(pitch_id) if !pitch_id.blank?
          user = ::User.find(user_id)
          member = ::User.find(member_id)
          program = ::Program.find(program_id)
          community_feed = ::CommunityFeed.find(community_feed_id)
          ::UserMailer.immediate_post_mail(member, community_feed, user, program, pitch).deliver
      end
    end

    class RegisteredEvent
    @queue = :background_mailer

      def self.perform(user_id, event_session_id)
        event_session = ::EventSession.find(event_session_id)
        user = ::User.find(user_id)
        ::UserMailer.registered_for_event(user, event_session).deliver
      end
    end

    class EventFull
    @queue = :background_mailer

      def self.perform(user_id, event_session_id)
        event_session = ::EventSession.find(event_session_id)
        user = ::User.find(user_id)
        ::UserMailer.event_full(user, event_session).deliver
      end
    end

    class EventsReminder
    @queue = :background_mailer

      def self.perform( event_session_id, user_id)
        event_session = ::EventSession.find(event_session_id)
        user = ::User.find(user_id)
        ::UserMailer.events_reminder(user, event_session).deliver
      end
    end

    class AssignedMentor
    @queue = :background_mailer

      def self.perform( admin_id, pitch_id, user_id)
        pitch = ::Pitch.find(pitch_id)
        user = ::User.find(user_id)
        admin = ::User.find(admin_id)
        ::UserMailer.assigned_mentor(admin, pitch, user).deliver
      end
    end

    class MemberJoinedTeam
       @queue = :background_mailer
      def self.perform(user_id,pitch_id)
         user = ::User.find(user_id)
         pitch = Pitch.find(pitch_id)
         resource =pitch.program
          if resource.customize_admin_emails.where(:email_name => "join_team_email").present?
            customize_admin_emails = resource.customize_admin_emails.where(:email_name => "join_team_email").first.description
            customize_admin_emails_subject = resource.customize_admin_emails.where(:email_name => "join_team_email").first.subject
             if customize_admin_emails_subject.nil?
               customize_admin_emails_subject = false
             end
             ::UserMailer.member_joined_team(user, resource, pitch, customize_admin_emails, customize_admin_emails_subject).deliver
          elsif CustomizeAdminEmail.where(:email_name => "join_team_email", :role_type => "super_admin").present?
            customize_admin_emails = CustomizeAdminEmail.where(:email_name => "join_team_email", :role_type => "super_admin").first.description
            customize_admin_emails_subject = CustomizeAdminEmail.where(:email_name => "join_team_email", :role_type => "super_admin").first.subject
             if customize_admin_emails_subject.nil?
               customize_admin_emails_subject = false
             end
             ::UserMailer.member_joined_team(user, resource, pitch,customize_admin_emails, customize_admin_emails_subject).deliver
          else
            customize_admin_emails = false
            subject =false
            ::UserMailer.member_joined_team(user, resource, pitch, customize_admin_emails, subject).deliver
           
        end
      end
    end

    class MemberNotAccepted
       @queue = :background_mailer
      def self.perform(user_id,pitch_id)
         user = ::User.find(user_id)
         pitch = Pitch.find(pitch_id)
         resource =pitch.program
          if resource.customize_admin_emails.where(:email_name => "declines_join_team_request").present?
            customize_admin_emails = resource.customize_admin_emails.where(:email_name => "declines_join_team_request").first.description
            customize_admin_emails_subject = resource.customize_admin_emails.where(:email_name => "declines_join_team_request").first.subject
             if customize_admin_emails_subject.nil?
               customize_admin_emails_subject = false
             end
             ::UserMailer.member_not_accepted(user, resource, pitch, customize_admin_emails, customize_admin_emails_subject).deliver
          elsif CustomizeAdminEmail.where(:email_name => "declines_join_team_request", :role_type => "super_admin").present?
            customize_admin_emails = CustomizeAdminEmail.where(:email_name => "declines_join_team_request", :role_type => "super_admin").first.description
            customize_admin_emails_subject = CustomizeAdminEmail.where(:email_name => "declines_join_team_request", :role_type => "super_admin").first.subject
             if customize_admin_emails_subject.nil?
               customize_admin_emails_subject = false
             end
             ::UserMailer.member_not_accepted(user, resource, pitch,customize_admin_emails, customize_admin_emails_subject).deliver
          else
            customize_admin_emails = false
            subject =false
            ::UserMailer.member_not_accepted(user, resource, pitch, customize_admin_emails, subject).deliver
           
        end
      end
    end

    class RateEventSession
       @queue = :background_mailer
      def self.perform(event_session_id , user_id)
        event_session = ::EventSession.find(event_session_id)
        user = ::User.find(user_id)
        resource = event_session.program_event.program
        if resource.customize_admin_emails.where(:email_name => "rate_events").present?
          customize_admin_emails = resource.customize_admin_emails.where(:email_name => "rate_events").first.description
          customize_admin_emails_subject = resource.customize_admin_emails.where(:email_name => "rate_events").first.subject
           if customize_admin_emails_subject.nil?
             customize_admin_emails_subject = false
           end
           ::UserMailer.rate_event_session(user, event_session, resource, customize_admin_emails, customize_admin_emails_subject).deliver
        elsif CustomizeAdminEmail.where(:email_name => "rate_events", :role_type => "super_admin").present?
          customize_admin_emails = CustomizeAdminEmail.where(:email_name => "rate_events", :role_type => "super_admin").first.description
          customize_admin_emails_subject = CustomizeAdminEmail.where(:email_name => "rate_events", :role_type => "super_admin").first.subject
           if customize_admin_emails_subject.nil?
             customize_admin_emails_subject = false
           end
           ::UserMailer.rate_event_session(user, event_session, resource, customize_admin_emails, customize_admin_emails_subject).deliver
        else
          customize_admin_emails = false
          subject =false
          ::UserMailer.rate_event_session(user, event_session, resource, customize_admin_emails, subject).deliver
        end
      end
    end

    class GenerateCommunityFeed
      @queue = :background_mailer
      def self.perform(activity_note_id)
        activity_note = ActivityNote.find(activity_note_id)
        pitch = activity_note.try(:activity_performance).try(:pitch)
        community_feed = CommunityFeed.create!(:content=>activity_note.notes, :organisation_id => pitch.try(:program).try(:organisation).try(:id) , :program_id => pitch.try(:program_id), :post_to=> "all", :created_by_id=> activity_note.try(:activity_performance).try(:user_id), :pitch_id => pitch.try(:id))
        activity_note.community_feed_id = community_feed.id
        activity_note.save
      end
    end

    class UpdateCommunityFeed
      @queue = :background_mailer
      def self.perform(activity_note_id)
        activity_note = ActivityNote.find(activity_note_id)
        community_feed = activity_note.community_feed
        community_feed.content = activity_note.notes
        community_feed.save
      end
    end

    class DeleteCommunityFeed
      @queue = :background_mailer
      def self.perform(community_feed_id)
        community_feed = CommunityFeed.find(community_feed_id)
        community_feed.destroy
      end
    end

    class SendReport
       @queue = :background_mailer
      def self.perform(user_id,report_id, prog_id) 
         user = ::User.find(user_id)          
         report = ::CustomReport.find(report_id)

               
        ::UserMailer.send_report(user, report, prog_id).deliver
      end
      
    end

  end

end