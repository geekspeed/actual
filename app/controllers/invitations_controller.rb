class InvitationsController < Devise::InvitationsController

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    @program = Program.where(id: params[:for]).first if params[:for].present?
    resource.invitation_token = params[:invitation_token]
    render :edit
  end

  def accept
    @program = Program.where(id: params[:for]).first if params[:for].present?
    @org = Organisation.where(id: params[:for]).first if params[:for].present?
    approved = true
    if @program.try(:program_scope).try(:email_restriction).present?
      @domain_name=@program.try(:program_scope).try(:email_restriction)
    end    
    if user_signed_in?
      if (params[:role] != "panellist" and params[:role] != "selector") and @program.try(:program_scope).try("manual_approval_for_#{params[:role]}")
        current_user.awaiting_for_approval params[:role], params[:for]
        approved = false
      else
        current_user.add_role(params[:role], params[:for])
      end
      redirect_to root_path(:approved => approved)
    else
      @resource = User.where(id: params[:user]).first || User.new
      @resource.invitation_token = params[:invitation_token]
      if session[:user_details]
        @user_details=session[:user_details]
        @resource.salutation=@user_details[:salutation]
        @resource.first_name=@user_details[:first_name]
        @resource.last_name=@user_details[:last_name]
        @resource.email=@user_details[:email]
        @resource.organisation=@user_details[:organisation]
      end   
      render :edit
    end
  end
  
  def check_email
    exist = User.where(email: params[:email]).first     
    render json: { status: "ok", exist: !!exist, 
      email: params[:email], :domain_check => (( !params[:email].include? params[:domain_name]) ? true : false) }

  end

  def find_user
    user = User.where(email: params[:email]).first
    render json: { status: "ok", user: !!user, 
      email: user.try(:email), first_name: user.try(:first_name),
      last_name:user.try(:last_name), first_name_hidden: user.try(:first_name_hidden),
      last_name_hidden:user.try(:last_name_hidden),anonymous: user.try(:anonymous), company:user.try(:company_name),
      salutation:user.try(:salutation) }
  end

  def invite_existing
    program = Program.find(params[:for])
    invitation = program.program_invitation
    invitation_mail = invitation.program_invitation_mail
    message = if params[:role] == "participant"
      invitation_mail.applicant_message["applicant_invitee"]
    elsif params[:role] == "mentor"
      invitation_mail.mentors_message["mentors_invitee"]
    elsif params[:role] == "selector"
      invitation_mail.selectors_message["selectors_invitee"]
    else
      invitation_mail.panel_message["panel_invitee"]
    end
    if params[:email].present?
      User.invitation_message(params[:email], program, params[:role], message, invitation_mail.id)
      flash[:notice] = "Invited successfully, We have just emailed you a registration link"
    else
      flash[:notice] = "There is some issue using exiting account, try enabling browser javascript"
    end
    redirect_to :back
  end

  private

  def resource_from_invitation_token
    if params[:invitation_token] == "0"
      self.resource = User.new()
    else
      super
    end
  end

  def after_accept_path_for(resource)
    step_2_user_registration_path(resource)
  end  
  
end
