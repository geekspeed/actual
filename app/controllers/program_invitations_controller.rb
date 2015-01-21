class ProgramInvitationsController < ApplicationController
  before_filter :load_program
  
  def new
    @invitation = @program.build_program_invitation
    mails = ProgramInvitation.where(:program_id => @program.id).last
    if !mails.blank? && !mails.program_invitation_mail.blank?
      @program_invitation_mails=ProgramInvitation.where(:program_id => @program.id).last.program_invitation_mail
    elsif !ProgramInvitationMail.where(:role_type => "super_admin").last.blank?
      @program_invitation_mails=ProgramInvitationMail.where(:role_type => "super_admin").last
    end
  end

  def create
    @invitation = @program.build_program_invitation
    if @program.master_program?
       @invitation_mail =  @invitation.build_program_invitation_mail(
        :program_admins_message => params[:message][:program_admin])
    else
      @invitation_mail =  @invitation.build_program_invitation_mail(:applicant_message => params[:message][:applicant], :selectors_message => params[:message][:selectors], :panel_message => params[:message][:panel], :mentors_message => params[:message][:mentors])
    end
    @invitation_mail.save
    if @invitation.save
      if params[:from_invites]
        redirect_to invites_program_invitation_url(@program)
      else
        redirect_to new_program_invitation_path(@program)
      end
    else
      render :action => :new
    end
  end

  def edit
    @invitation = @program.program_invitation
  end

  def update
    @invitation = @program.program_invitation
    if @invitation.update_attributes(params[:program_invitation])
      flash[:notice] = "Program invitation updated successfully."
      redirect_to :back
    else
      render :action => :edit
    end
  end
 
  def invites
    @invitation = @program.build_program_invitation
    program_id = @program.id.to_s
    @selectors = User.any_of(:"_invited_selector".in => [program_id])
      .any_of(:"_selector".in => [program_id])
    @panellists = User.any_of(:"_invited_panellist".in => [program_id])
      .any_of(:"_panellist".in => [program_id])
    @mentors = User.any_of(:"_invited_mentor".in => [program_id])
      .any_of(:"_mentor".in => [program_id])
    @registered_applicants = User.in("_participant" => [program_id])
    @not_registered_applicants = User.in("_invited_participant" => [program_id])
  end
 
  def send_invites
    @invitation = @program.build_program_invitation(params[:program_invitation])
    previous_mails = ProgramInvitation.where(:program_id => @program.id).last.try(:program_invitation_mail)
    begin
      new_invitation_mail =  previous_mails.dup 
      new_invitation_mail.program_invitation_id = @invitation.id
      new_invitation_mail.save
      User.send_invitation_messages(params[:program_invitation], @program, new_invitation_mail.id)
    rescue Exception => e
      flash[:notice] = "Please add invitations before sending."
      redirect_to new_program_invitation_path(@program, from_invites: true) and return
    end
    if @invitation.save
      flash[:notice] = "Invite Succesfully Send."
      redirect_to :back
    else
      redirect_to :back
    end
  end

  private

  def load_program
    @program = Program.find(params[:program_id]) if params[:program_id].present?
  end
end
