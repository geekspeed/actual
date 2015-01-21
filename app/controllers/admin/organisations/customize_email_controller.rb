class Admin::Organisations::CustomizeEmailController < ApplicationController
  def feedback_emails
    @page = "setup"
  end

  def feedback_emails_save
    if params[:feedback].present?
      params[:feedback].each_with_index do |feedback, index|
        if CustomizeAdminEmail.where(:from => feedback[0], :email_name => "feedback", :role_type => "super_admin").present?
          @feedback_mail_update = CustomizeAdminEmail.where(:from => feedback[0], :email_name => "feedback", :role_type => "super_admin").first
          @feedback_mail_update.update_attributes(:user_id => current_user.id, :email_name=>"feedback", :subject => params[:subject].values[index], :description => feedback[1], :from => feedback[0], :role_type => "super_admin")
          @feedback_mail_update.save
        else
          @feedback_mail = current_user.customize_admin_emails.create(:email_name=>"feedback", :subject => params[:subject].values[index], :description => feedback[1], :from => feedback[0], :role_type => "super_admin")
          @feedback_mail.save
        end
      end
      flash[:notice] = "Feedback email updated successfully"
    else
      flash[:error] = "Something goes wrong"
    end    
    redirect_to :back
  end

  def comment_emails
    @page = "setup"
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
    @page = "setup"
    if CustomizeAdminEmail.where(:email_name => "admin_invite", :role_type => "super_admin").present?
       @admin_mail_update = CustomizeAdminEmail.where(:email_name => "admin_invite", :role_type => "super_admin").first.description 
       @admin_subject = CustomizeAdminEmail.where(:from => "admin", :email_name => "admin_invite", :role_type => "super_admin").first.subject 
    end
  end

  def admin_invite_save
    if CustomizeAdminEmail.where(:email_name => "admin_invite", :role_type => "super_admin").present?
      @admin_mail_update =  CustomizeAdminEmail.where(:email_name => "admin_invite", :role_type => "super_admin").first
      @admin_mail_update.update_attributes(:user_id => current_user.id, :email_name=>"admin_invite", :description => params[:feedback][:admin_invite], :from => "admin",:subject=>params[:subject][:admin], :role_type => "super_admin", :role_type => "super_admin")
    else
      current_user.customize_admin_emails.create(:email_name=>"admin_invite", :description => params[:feedback][:admin_invite], :from => "admin",:subject=>params[:subject][:admin], :role_type => "super_admin")
    end
    redirect_to :back
  end

  def team_member_invite
    @page = "setup"
    if CustomizeAdminEmail.where(:email_name => "team_member_invite", :role_type => "super_admin").present?
      @team_member =  CustomizeAdminEmail.where(:email_name => "team_member_invite", :role_type => "super_admin").first.description 
      @team_member_subject = CustomizeAdminEmail.where(:email_name => "team_member_invite", :role_type => "super_admin").first.subject 
    end
  end

  def team_member_invite_save
    if CustomizeAdminEmail.where(:email_name => "team_member_invite", :role_type => "super_admin").present?
      @team_member = CustomizeAdminEmail.where(:email_name => "team_member_invite", :role_type => "super_admin").first
      @team_member.update_attributes(:user_id => current_user.id, :email_name=>"team_member_invite", :description => params[:feedback][:team_member_invite], :from => "project_member",:subject=>params[:subject][:admin], :role_type => "super_admin")
    else
      current_user.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"team_member_invite", :description => params[:feedback][:team_member_invite], :from => "project_member",:subject=>params[:subject][:admin], :role_type => "super_admin")
    end
    redirect_to :back
  end

  def team_mentor_invite
    @page = "setup"
    if CustomizeAdminEmail.where(:email_name => "team_mentor_invite", :role_type => "super_admin").present?
      @team_mentor =  CustomizeAdminEmail.where(:email_name => "team_mentor_invite", :role_type => "super_admin").first.description 
      @team_mentor_subject = CustomizeAdminEmail.where(:email_name => "team_mentor_invite", :role_type => "super_admin").first.subject 
    end
  end

  def team_mentor_invite_save
    if CustomizeAdminEmail.where(:email_name => "team_mentor_invite", :role_type => "super_admin").present?
      @team_mentor = CustomizeAdminEmail.where(:email_name => "team_mentor_invite", :role_type => "super_admin").first
      @team_mentor.update_attributes(:user_id => current_user.id, :email_name=>"team_mentor_invite", :description => params[:feedback][:team_mentor_invite], :from => "project_member",:subject=>params[:subject][:admin], :role_type => "super_admin")
    else
      current_user.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"team_mentor_invite", :description => params[:feedback][:team_mentor_invite], :from => "project_member",:subject=>params[:subject][:admin], :role_type => "super_admin")
    end
    redirect_to :back
  end

  def mentor_offer_invite
    @page = "setup"
    if CustomizeAdminEmail.where(:email_name => "mentor_offer", :role_type => "super_admin").present?
      @mentor_offer = CustomizeAdminEmail.where(:email_name => "mentor_offer", :role_type => "super_admin").first.description 
      @mentor_subject = CustomizeAdminEmail.where(:email_name => "mentor_offer", :role_type => "super_admin").first.subject 
    end
  end

  def mentor_offer_invite_save
    if CustomizeAdminEmail.where(:email_name => "mentor_offer", :role_type => "super_admin").present?
      @mentor_offer = CustomizeAdminEmail.where(:email_name => "mentor_offer", :role_type => "super_admin").first
      @mentor_offer.update_attributes(:user_id => current_user.id, :email_name=>"mentor_offer", :description => params[:feedback]["mentor_offer"], :from => "mentor",:subject=>params[:subject][:admin], :role_type => "super_admin")
    else
     current_user.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"mentor_offer", :description => params[:feedback]["mentor_offer"], :from => "mentor",:subject=>params[:subject][:admin], :role_type => "super_admin")
    end
    redirect_to :back
  end

 def join_team
    if CustomizeAdminEmail.where(:email_name => "join_team", :role_type => "super_admin").present?
      @join_team =  CustomizeAdminEmail.where(:email_name => "join_team", :role_type => "super_admin").first.description 
      @join_team_subject = CustomizeAdminEmail.where(:email_name => "join_team", :role_type => "super_admin").first.subject 
    end
  end

  def join_team_save
    if CustomizeAdminEmail.where(:email_name => "join_team").present?
      @join_team =  CustomizeAdminEmail.where(:email_name => "join_team").first
      @join_team.update_attributes(:user_id => current_user.id, :email_name=>"join_team", :description => params[:feedback]["join_team"],:subject=>params[:subject][:join_team], :role_type => "super_admin")
    else
      current_user.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"join_team", :description => params[:feedback]["join_team"],:subject=>params[:subject][:join_team], :role_type => "super_admin")
    end
    redirect_to :back
  end

 def submit_pitch
    unless CustomizeAdminEmail.where(:email_name => "submit_pitch", :role_type => "super_admin").present?
      current_user.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"submit_pitch", :description =>"<div>Dear team #projectname<br></div><div><br></div><div>Thanks a lot for submitting your #projectsemantic.<br></div><div><br></div><div>The jury will soon be voting and we will come back to you as soon as this is done!<br></div><div><br></div><div>#programname<br></div>", :subject=>"Thanks for submitting your project!", :role_type => "super_admin")
    end
    @submit_pitch =  CustomizeAdminEmail.where(:email_name => "submit_pitch", :role_type => "super_admin").first.description 
    @submit_pitch_subject = CustomizeAdminEmail.where(:email_name => "submit_pitch", :role_type => "super_admin").first.subject 
  end

  def submit_pitch_save
    if CustomizeAdminEmail.where(:email_name => "submit_pitch").present?
      @submit_pitch =  CustomizeAdminEmail.where(:email_name => "submit_pitch").first
      @submit_pitch.update_attributes(:user_id => current_user.id, :email_name=>"submit_pitch", :description => params[:feedback]["submit_pitch"],:subject=>params[:subject][:submit_pitch], :role_type => "super_admin")
    else
      current_user.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"submit_pitch", :description => params[:feedback]["submit_pitch"],:subject=>params[:subject][:submit_pitch], :role_type => "super_admin")
    end
    redirect_to :back
  end

  private

  def comment_list_save(user_type,comment)
    if comment[0].present?
      if comment[1][:comment].present? ||  comment[1][:subject].present?
        comment[1][:comment].each_with_index do |new_comment, index|
          if CustomizeAdminEmail.where(:from => user_type , :to => new_comment[0], :email_name => "comments", :role_type => "super_admin").present?
            @comment_mail_update = CustomizeAdminEmail.where(:from => user_type, :to => new_comment[0], :email_name => "comments", :role_type => "super_admin").first
            @comment_mail_update.update_attributes(:user_id => current_user.id, :email_name=>"comments", :subject => comment[1][:subject].values[index], :description => new_comment[1], :from => user_type, :to => new_comment[0], :role_type => "super_admin")
            @comment_mail_update.save
          else
            @comment_email = current_user.customize_admin_emails.create(:user_id => current_user.id, :email_name=>"comments", :subject => comment[1][:subject].values[index], :description => new_comment[1], :from => user_type, :to => new_comment[0], :role_type => "super_admin")
            @comment_email.save
          end
        end
      end
    end
  end

end
