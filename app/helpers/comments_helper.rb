module CommentsHelper

  def comment_email_subject(from,to,mail_type)
    if current_user.super_admin?
   	  if CustomizeAdminEmail.where(:from => from,:to => to, :email_name => mail_type, :role_type => "super_admin").first.present? && CustomizeAdminEmail.where(:from => from,:to => to, :email_name => mail_type, :role_type => "super_admin").first.subject.present?  
        CustomizeAdminEmail.where(:from => from, :to => to, :email_name =>mail_type, :role_type => "super_admin").first.subject
      end
    else
      if @program.customize_admin_emails.where(:from => from,:to => to, :email_name => mail_type).first.present? && @program.customize_admin_emails.where(:from => from,:to => to, :email_name => mail_type).first.subject.present?  
        @program.customize_admin_emails.where(:from => from, :to => to, :email_name =>mail_type).first.subject
      end
    end
  end

  def comment_email_description(from,to,mail_type)
    if current_user.super_admin?
      if CustomizeAdminEmail.where(:from => from,:to => to, :email_name => mail_type, :role_type => "super_admin").first.present? && CustomizeAdminEmail.where(:from => from,:to => to, :email_name => mail_type, :role_type => "super_admin").first.description.present?  
        CustomizeAdminEmail.where(:from => from, :to => to, :email_name =>mail_type, :role_type => "super_admin").first.description
      end
    else
      if @program.customize_admin_emails.where(:from => from,:to => to, :email_name => mail_type).first.present? && @program.customize_admin_emails.where(:from => from,:to => to, :email_name => mail_type).first.description.present? 
        @program.customize_admin_emails.where(:from => from, :to => to, :email_name =>mail_type).first.description
      end
    end
  end

  def feedback_email_subject(from,email_type)
    if current_user.super_admin?
      if CustomizeAdminEmail.where(:from => from, :email_name => email_type, :role_type => "super_admin").first.present? && CustomizeAdminEmail.where(:from => from, :email_name => email_type, :role_type => "super_admin").first.subject.present?  
        CustomizeAdminEmail.where(:from => from, :email_name => email_type).first.subject
      end
    else
      if @program.customize_admin_emails.where(:from => from, :email_name => email_type).first.present? && @program.customize_admin_emails.where(:from => from, :email_name => email_type).first.subject.present?  
        @program.customize_admin_emails.where(:from => from, :email_name => email_type).first.subject
      end
    end
  end

  def feedback_email_description(from,email_type)
    if current_user.super_admin?
      if CustomizeAdminEmail.where(:from => from, :email_name => email_type, :role_type => "super_admin").first.present? && CustomizeAdminEmail.where(:from => from, :email_name => email_type, :role_type => "super_admin").first.description.present?
        CustomizeAdminEmail.where(:from => from, :email_name => email_type).first.description
      end
    else
      if @program.customize_admin_emails.where(:from => from, :email_name => email_type).first.present? && @program.customize_admin_emails.where(:from => from, :email_name => email_type).first.description.present?  
        @program.customize_admin_emails.where(:from => from, :email_name => email_type).first.description
      end
    end
  end
  
end