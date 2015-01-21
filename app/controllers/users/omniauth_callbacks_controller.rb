class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def linkedin
    current_user ? connect_to_linkedin : sign_in_via_linkedin
  end

  def facebook
    program_id = request.env['omniauth.params']["program_id"]
    program = Program.where(id: program_id).first
    role_type = request.env['omniauth.params']["role"]
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"])
    if @user and @user.persisted?
      old_program = old_program?(@user, program)
      approved = approval_for_programs(@user, program, role_type, program_id)
      sign_in(@user)
      (@user.sign_in_count == 1 or !old_program) ? (redirect_to about_me_registration_path(:social_media => true)) : (redirect_to root_path(:approved => approved))
    else
      if @user.nil?
        flash[:notice] = "User with this email already exist."
      end
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_session_url
    end
  end

  def twitter
    auth = env["omniauth.auth"]

    @program = context_program
    @user = User.find_for_twitter_oauth(request.env["omniauth.auth"],current_user)
    unless @user.new_record?
      old_program = old_program?(@user, context_program)
      approved = approval_for_programs(@user, context_program, params[:role], params[:program_id])
      sign_in(@user)
      redirect_to old_program ? root_path(:approved => approved) : about_me_registration_path(:social_media => true)
    end
  end

  def create_twitter_user
    begin
      user = User.create!(params[:user])
      #user.confirm!
      approved = approval_for_programs(user, context_program, params[:role], params[:program_id])
      sign_in(user)
      redirect_to root_path(:approved => approved)
    rescue Exception => e
      if e.message.match("E-Mail is already taken")
        flash[:notice] = "User with this email already exist."
      end
      redirect_to new_user_session_url
    end
  end

  private
  
  def connect_to_linkedin
    if current_user.connect_to_linkedin(request.env["omniauth.auth"])
      set_flash_message(:notice, :success, :kind => "LinkedIn")
    else
      set_flash_message(:notice, :failure, :kind => "LinkedIn")
    end
    redirect_to root_url
  end
  
  def sign_in_via_linkedin
    @user = User.find_for_linkedin_oauth(request.env["omniauth.auth"])
    if @user
      old_program = old_program?(@user, context_program)
      approved = approval_for_programs(@user, context_program, params[:role], params[:program_id])
      sign_in(@user)
      (@user.sign_in_count == 1 or !old_program) ? (redirect_to about_me_registration_path(:social_media => true)) : (redirect_to root_path(:approved => approved))
      set_flash_message(:notice, :success, :kind => "LinkedIn") if is_navigational_format?
    else
      if @user.nil?
        flash[:notice] = "User with this email already exist."
      else
        flash[:notice] = "Couldn't find a user connected to your LinkedIn account. Please sign in and then connect your account to LinkedIn."
      end
      redirect_to new_user_session_url
    end
  end

  def approval_for_programs(user, program, role, program_idd)
    manual_approval = (program and program.program_scope and program.program_scope.fields.include?("manual_approval_for_#{role}")) ? program.program_scope.try("manual_approval_for_#{role}") : false
    session.delete('context_program') if manual_approval
    approved = true
    #user.connect_to_linkedin(request.env["omniauth.auth"])
    if manual_approval
      user.awaiting_for_approval role, program_idd
      approved = false
    else
      user.add_role(role, program_idd)
    end
    return approved
  end

  def old_program?(user, context_program=nil)
    existing_program = [user].map{|m| [ m["_mentor"], m["_participant"], m["_panellist"], m["_selector"] ]}.flatten.compact
    old_program = existing_program.include? context_program.id
  end

end