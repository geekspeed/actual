class CommunityFeedMailer < ActionMailer::Base
  include Devise::Mailers::Helpers
  # default from: Devise.mailer_sender

  def comments(comment_id, user_id)
    @user = User.find(user_id)
    @comment = Comment.find(comment_id)
    @commentable = @comment.commentable
    @commenter = @comment.commented_by
    @program = @comment.commentable.program
    if @program.customize_admin_emails.where(:email_name => "comments").present?
        customize_admin_emails = @program.customize_admin_emails
        comment_fetch(nil,customize_admin_emails)
    elsif CustomizeAdminEmail.where(:email_name => "comments", :role_type => "super_admin").present?
        customize_admin_emails = CustomizeAdminEmail
        comment_fetch("super_admin",customize_admin_emails)
    else 
        @comment_email = @comment
        @subject = "Comment on feed"
        @present = false
    end
    @domain_host = DomainMapping.domain(@program)
    mail(to: @user.email, subject: @subject, from: "#{@program.title} <info@apptual.com>")
  end
  private

  def comment_fetch(role_type,customize_admin_emails)
    from = comment_role_fix(@commenter.roles_string_for(@program.id, @program.organisation.id))
    to = comment_role_fix(@user.roles_string_for(@program.id, @program.organisation.id))
    mail_details = prepare_customize_email(from,to,role_type,customize_admin_emails)
    @subject = mail_details[:subject]
    @email = mail_details[:email]
    @comment_email = @email.gsub("#from",@commenter.first_name).gsub("#to",@user.first_name).gsub("#programname",@program.title).gsub("#companyname",@program.organisation.company_name).gsub("#comment",@comment.content).gsub("#projectname",@comment.commentable.try(:pitch).try(:title).to_s)
    @present = true
  end

  def comment_role_fix(role_type)
    role_type[0] == "company_admin" ? "admin" : (role_type[0] == "panellist" ? "panel" : role_type[0])
  end

  def prepare_customize_email(from,to,role_type,customize_admin_emails) 
    if customize_admin_emails.where(:from => from, :to => to, :email_name => "comments", :role_type => role_type).first.present?
      mail = Hash.new
      mail[:email] = customize_admin_emails.where(:from => from, :to => to, :email_name => "comments", :role_type => role_type).first.description
      mail[:subject] = customize_admin_emails.where(:from => from, :to => to, :email_name => "comments", :role_type => role_type).first.subject
      return mail
    end
  end

end
