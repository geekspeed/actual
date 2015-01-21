class ConfirmationsController < Devise::ConfirmationsController

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      organisation = !resource["_company_admin"].blank? ? Organisation.where(id: resource["_company_admin"].try(:first)).first : Organisation.where(id: resource["_ecosystem_member"].try(:first)).first      
      resource.send_admin_welcome_message(resource.try(:id), organisation.try(:id)) if resource.role?("company_admin", organisation.try(:id))
      sign_in(resource)
      resource_path  =  resource.role?("ecosystem_member", organisation.try(:id)) ? organisation_path(organisation.try(:id), :welcome => true) : root_path
      (resource.provider == "twitter") ? (redirect_to about_me_registration_path(:social_media => true)) : (redirect_to resource_path)
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
    end
  end

end