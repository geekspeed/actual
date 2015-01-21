class Admin::OrganisationsController < ApplicationController

  before_filter :authorize_super_admin

  def index
    @page = "index"
    @organisations = Organisation.all
  end

  def setup
  	@page = "setup"
  end

  def customize_email
    @page = "setup"
  end

  def role_invitation
    @page = "setup"
    if !ProgramInvitation.blank?
      @program_invitation_mails=ProgramInvitationMail.where(:role_type => "super_admin").last
    end
  end

  def role_invitation_save
    @page = "setup"
    if ProgramInvitationMail.where(:role_type => "super_admin").last.present?
      @invitation_mail = ProgramInvitationMail.where(:role_type => "super_admin").last
      @invitation = @invitation_mail.update_attributes(:applicant_message => params[:message][:applicant], :selectors_message => params[:message][:selectors], :panel_message => params[:message][:panel], :mentors_message => params[:message][:mentors], :role_type => "super_admin")
    else
      @invitation_mail = ProgramInvitationMail.create(:applicant_message => params[:message][:applicant], :selectors_message => params[:message][:selectors], :panel_message => params[:message][:panel], :mentors_message => params[:message][:mentors], :role_type => "super_admin")
    end
      flash[:notice] = "Program invitation updated successfully."
      redirect_to :back
  end

  def toggle
    @organisation = Organisation.find(params[:id])
    @organisation.toggle_status!
    redirect_to :action => :index
  end
end
