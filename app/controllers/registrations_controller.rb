
class RegistrationsController < Devise::RegistrationsController
	prepend_before_filter :require_no_authentication, :only => [ :new, :create,
		:cancel, :step_2, :update_without_session ]
  prepend_before_filter :authenticate_scope!, :only => [:show, :edit, :update, :destroy]

  def show
    @user = User.find(params[:id])
    @pitches = (!!context_program ? context_program.pitches.or(:user_id => @user.id.to_s).
                or(:members => @user.id.to_s).or(:mentors => @user.id.to_s) : [])
    @user_badges = @user.user_badges.active_badges
    @buzz_feeds = CommunityFeed.in(created_by_id: @user.id, activity: false).limit(5)
    render layout: "layouts/application_new_design"
  end
	# POST /resource
  def create
    build_resource
    resource.skip_confirmation_notification!
    begin 
      resource.save!
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    rescue Exception => e
      if e.message.include? "E-Mail is invalid"
        flash[:notice]= "E-Mail is invalid."
      elsif e.message.include? "Password is too short"
        flash[:notice]= "The password you entered is too short, password should be minimum 8 characters long."
      elsif e.message.include? "Password doesn't match confirmation"
        flash[:notice]=  "Your password does not match the confirm password. Please enter the same password in both fields."          
      else            
        flash[:notice]= e.message
      end
      clean_up_passwords resource
      respond_with resource
    end
  end

	# PUT /resource
	# We need to use a copy of the resource because we don't want to change
	# the current user in place.
	def accept_invitation
		redirect_to root_path and return if params[:commit] == "Decline"

		user_obj = User.where(email: params[:user][:email]).first
		Rails.logger.warn "------User last_email_at is null #{user_obj.try(:inspect)} #{params[:user][:email]} is #{user_obj.try(:email)} #{params} ha this"
		if (user_obj and user_obj.email.present?)
		  if params[:user][:password] == params[:user][:password_confirmation] and user_obj.valid_password?(params[:user][:password])
		   #user.update_attributes(params[:user])
		   params[:user_id] = user_obj.id
		  else
		    flash[:notice] = "Please verify and confirm password"
		    redirect_to :back and return
		  end
		end
    self.resource = User.accept_invitation!(params[:user], {:for => params[:for], :role_code => params[:role_code], :user_id => params[:user_id], :current_user => current_user})
    program = Program.find(params[:for]) rescue nil
    if !resource.is_a? User
      if params[:user][:invitation_token] == "0"
        flash[:notice] = resource
        exist = User.where(email: params[:user][:email]).first
        if !!exist
          redirect_to [request.env["HTTP_REFERER"], "user=#{exist.id}"].join("&")
        else
          session[:user_details]=params[:user]
          redirect_to :back
        end
      else
        set_flash_message :notice, "Invalid invitation token."
        redirect_to new_user_session_path
      end
    elsif resource.errors.empty?
      session[:user_details]=nil
      if params[:for_pitch].present?
        pitch = Pitch.find(params[:for_pitch])
        pitch.add_to_members!(resource.id.to_s)
        #for storing the activity details
        if program
          ActivityFeed.create(:type=>"pitch_member", :user_id => @user.id, :pitch_id=> params[:for_pitch], :program_id => params[:for])
        end
      end
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message :notice, flash_message
      # sign_in(resource_name, resource)
      # if params[:program_invitation_mail_id].present?
        # welcome_messages(@user.id)
      # end
      manual_approval = manual_approval_and_inform_admin(resource, params[:for], params[:role_code])
      #for storing the activity details
      if program and user_obj.nil?
        ActivityFeed.create(:type=>"join_program", :user_id => @user.id, :role_code => params[:role_code], :program_id => params[:for], :awaiting => manual_approval)
      end
      respond_with resource, :location => after_accept_path_for(resource, {:for => params[:for], :role_code => params[:role_code]})
    else
      respond_with_navigational(resource){ render :edit }
    end
  end

  def finish
    @organisation = params[:org].present? && Organisation.find(params[:org])
    @user = params[:user] ? User.find(params[:user]) : current_user
    if params[:references].present?
      @role_code = params[:references][:role_code]
      @program = Program.where(id: params[:references][:for]).first
      @org = Organisation.where(id: params[:references][:for]).first
    end
  end

  def force_sign_in
    unless user_signed_in?
      self.resource = User.find(params[:id])
      autmatically_pitch_create(params[:id],params[:prg_id]) if (params[:id] && params[:prg_id])
      resource.send_confirmation_instructions unless resource.confirmed?
      manual_approval_and_inform_admin(resource, params[:prg_id], params[:role], true)
      sign_in(resource_name, resource)
    end
    redirect_to root_path
  end

  def update_without_session
    update_without_password
  end

	def update_about_me
		update_without_password
	end

	def step_2
    @reg_process = true
    if params[:references].present? && params[:references][:for].present?
      @program = Program.where(id: params[:references][:for]).first
      @org = Organisation.where(id: params[:references][:for]).first
    end
		@user = User.find(params[:id])
	end

	def about_me
		@user = current_user
		render :step_2
	end

	def after_inactive_sign_up_path_for(resource)
		step_2_user_registration_path(resource)
	end


  def after_step_2_path_for(resource, references={})
    references ||= {}
    if references[:role_code].present? && RoleType.on_programs.collect(&:code).include?(references[:role_code])
      finish_registration_path(user: resource.id, references: references)
    elsif references[:role_code].present? && RoleType.on_organisation.collect(&:code).include?(references[:role_code])
      finish_registration_path(user: resource.id, references: references)
    else
      new_organisation_path(:user => resource)
    end
  end

  def after_accept_path_for(resource, references={})
    step_2_user_registration_path(resource, references: references)
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    resource.skip_reconfirmation!

    if resource.update_with_password(resource_params)
      if is_navigational_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, :bypass => true
      flash[:notice] = "Password Successfully Changed!!"
      #respond_with resource, :location => after_update_path_for(resource)
      redirect_to dashboard_path
    elsif !resource.provider.nil?
      if resource.update_without_password(resource_params)
        flash[:notice] = "Account Successfully Updated!!"
        redirect_to :back
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def show_faq
    if user_signed_in? and context_program
      unless current_user.visited_faq_programs.map(&:program_id).include? context_program.id
        current_user.visited_faq_programs.create!(:program_id => context_program.id)
      end
      show = (current_user.visited_faq_programs.where(program_id: context_program.id).first.
              pages_visited.include? params[:data]) ? false : true
      render :json => show
    end
  end

  def pages_visited
    program_faq = current_user.visited_faq_programs.where(program_id: context_program.id).first
    unless program_faq.pages_visited.include? params[:data]
      program_faq.pages_visited << params[:data]
      program_faq.save!
    end
    render :json => false
  end

  def social_update
    if params[:user][:password].present? and params[:user][:password] == params[:user][:password_confirmation]
      if params[:user][:provider] == "linkedin"
        user = User.where(email: current_user.email).first
        user.update_attributes(password: params[:user][:password], provider: nil, username: nil, linkedin_access_secret: nil, linkedin_access_token: nil, linkedin_id: nil)
      else
        user = User.where(email: current_user.email).first
        user.update_attributes(password: params[:user][:password], provider: nil, uid: nil)
      end
      flash[:notice] = "Unlinked from social login"
    else
      flash[:notice] = "Password doesn't match confirmation"
    end
    redirect_to :back
  end

  def edit_user
    @program = context_program
    @user = User.find(params[:user_id])
    render layout: false
  end

  def admin_update
    @user =  User.find(params[:user_id])
    
    new_params = upload_custom_field(params[:user], @user)
    flash.keep[:notice] = @user.errors.try(:full_messages).try(:first)
    redirect_to :back and return unless @user.try(:errors).blank?
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated successfully"
    else
      flash[:notice] = "There is some error editing user."
    end
    redirect_to :back
  end

	protected

	def update_without_password
		# required for settings form to submit when password is left blank
		if params[:user][:password].blank?
			params[:user].delete("password")
			params[:user].delete("password_confirmation")
		end
    @user = current_user || User.find(params[:id])
    
    new_params = upload_custom_field(params[:user], @user)
    flash.keep[:notice] = @user.errors.try(:full_messages).try(:first)
    redirect_to :back and return unless @user.try(:errors).blank?
    
    if @user.update_attributes(params[:user])
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      # sign_in @user, :bypass => true
      redirect_to user_signed_in? ? ((params[:social_media] == "true") ? finish_registration_path : :back) : after_step_2_path_for(@user, params[:references])
    else
      render user_signed_in? ? "about_me" : "step_2"
    end
  end

  def upload_custom_field(params, user)
    new_params = params
    custom_fields = User.custom_fields.enabled.for_program(get_program).where(element_type: "file_upload")
    custom_fields = custom_fields.for_anchor(get_custom_field_anchor) unless get_custom_field_anchor.blank?
    custom_fields.each do |c_fields|
      action_dispact = params[:custom_fields][(c_fields.code).to_sym] if params[:custom_fields]
      unless (action_dispact.blank? || action_dispact.class == String)
        if c_fields.options.blank? || (!c_fields.options.blank? and c_fields.options.include?(action_dispact.original_filename.split('.').try(:last).try(:downcase)))
          file_upload = c_fields.upload_file.find_or_initialize_by(for_class: User, class_id: user.id )
          file_upload.update_attributes(:avatar => action_dispact)
          new_params[:custom_fields][(c_fields.code).to_sym] = file_upload.try(:avatar).try(:url)
        else
          user.errors[:base] << "For Field #{c_fields.code} only #{c_fields.options} file type supported"
        end
      end
    end
    new_params
  end

  def welcome_messages(user_id, role, program_id)
    @program_invitation_mail = ProgramInvitation.where(:program_id => program_id).try(:last).try(:program_invitation_mail)
    if !@program_invitation_mail.blank?
      case role.present?
      when role == "participant" then
         @welcome_message = @program_invitation_mail.applicant_message["applicant_welcome"]
      when role == "selector" then
         @welcome_message = @program_invitation_mail.selectors_message["selectors_welcome"]
       when role == "panellist" then
         @welcome_message = @program_invitation_mail.panel_message["panel_welcome"]
       when role == "mentor" then
         @welcome_message = @program_invitation_mail.mentors_message["mentors_welcome"]
      end
      User.welcome_messages(user_id, role, @welcome_message, program_id)
    end
  end

  def manual_approval_and_inform_admin(resource, program_id, role, inform=nil)
    program = Program.where(id: program_id).first
    manual_approval = (program and program.program_scope and program.program_scope.fields.include?("manual_approval_for_#{role}")) ? 
                        program.program_scope.try("manual_approval_for_#{role}") : false
    User.message_to_admin_for_awaiting_users(resource.id, role, program.id) if manual_approval and inform
    welcome_messages(resource.id, role, program_id) if !manual_approval and inform and program_id
    return manual_approval
  end

  def autmatically_pitch_create(id,prg_id)
    program = Program.find(prg_id)        
    user = User.find(id)   
    if program.try(:program_scope).try(:automatically_create_project) && user.participant?(program)
      pitch = program.pitches.build(:title=>"#{user.first_name}'s #{Semantic.translate(program, "pitch", "singular")}")
      pitch.user = user
      pitch.build_summary
      program.activity_feeds.create(:type=>"pitch_create", :pitch_id => pitch.id, :user_id => user.id)
      program.activity_feeds.create(:type=>"pitch_create_program", :pitch_id => pitch.id, :user_id => user.id)
      pitch.save
    end
  end
end
