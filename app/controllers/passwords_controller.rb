class PasswordsController < Devise::PasswordsController
  prepend_before_filter :require_no_authentication
  # Render the #edit only if coming from a reset password email link
  append_before_filter :assert_reset_token_passed, :only => :edit

  # POST /resource/password
  def create
    user = User.where(email: resource_params[:email]).first
    if user and user.confirmed? and user.approved?
      self.resource = resource_class.send_reset_password_instructions(resource_params)

      if successfully_sent?(resource)
        #program = Program.where(id: params[:program_id]).first
        respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
      else
        respond_with(resource)
      end
    else
      flash[:notice] = "You haven't registered with apptual yet."
      redirect_to :back
    end
    
  end

end