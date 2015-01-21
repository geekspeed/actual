class OrganisationsController < ApplicationController

  skip_before_filter :authenticate_user!, :only => [:new, :create, :show, :add_new, :autosuggest, :eco_login, :contact_us]

  def show
    @organisation = Organisation.find(params[:id]) || current_organisation
    @programs = @organisation.programs.regular
    if params[:program_type].present?
      @programs = @programs.where(:program_type_id => params[:program_type])
    end
    render layout: "eco_summary"
  end

  def new
    @organisation = Organisation.new
    build_dependents
  end

  def create
    user_id = params[:organisation][:admins].first
    user = User.find(user_id)
    @organisation = Organisation.new(params[:organisation])
    if @organisation.save
      if params[:invites][:company_admin].present?
        @organisation.build_invitations(params[:invites], :company_admin)
      end
      user.update_role(:company_admin, @organisation.id.to_s)
      flash[:notice] = "Account created successfully"
      @organisation.create_badge_authority(name: @organisation.try(:company_name), url: organisation_url(@organisation))      
      # redirect_to :root
      redirect_to finish_registration_path(user: user_id, 
        org: @organisation.id)
    else
      render :new
    end
  end

  def edit
    @organisation = current_organisation
    build_dependents
  end

  def update
    @organisation = current_organisation
    if @organisation.update_attributes(params[:organisation])
       @organisation.build_invitations(params[:invites], :company_admin, current_user.try(:id))
      flash[:notice] = "Company account updated successfully."
      redirect_to :back
    else
      render :action => :edit
    end
  end

  def destroy

  end

  def members
    role_code = params[:role_code] || "participant"
    @organisation = current_organisation
    program_ids = @organisation.program_ids.collect(&:to_s)
    @users = User.in("_#{role_code}" => context_program ? context_program.id.to_s : "")
  end

  def buzz
    @organisation = current_organisation
    @feeds = CommunityFeed.feed_for_ecosystem(current_organisation).for_pitch(nil).page(params[:page])
    @feeds = @feeds.in(tags: params[:tag]) if params[:tag].present?
    # render :layout => "application_new_design"
  end

  def buzz_post
    # debugger
    @community_feed = CommunityFeed.new(params[:community_feed])
    @community_feed.created_by = current_user
    @community_feed.organisation = current_organisation
    if @community_feed.save
      flash[:notice] = "Feed saved successfully"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  def add_new
    @organisation = Organisation.new(params[:organisation])
    @organisation.save
  end

  def autosuggest
    @organisations = Organisation.any_of({company_name: /.*#{params[:name]}.*/i})
    respond_to do |format|
        format.json {render :json => @organisations}
    end
  end

  def popup_details
    @organisation = Organisation.find(params[:id])
  end

  def eco_login
    @organisation = Organisation.find(params[:id]) || current_organisation
    render layout: "eco_summary"
  end

  def faqs
    @organisation = Organisation.find(params[:id]) || current_organisation
    @faqs = @organisation.faqs.all.asc(:created_at)
  end

  def faq_save
    @organisation = Organisation.find(params[:id]) || current_organisation
    @organisation.update_attributes(params[:organisation])
    redirect_to :back
  end

  def faq_destroy
    if params[:id].present?
      faq = Faq.where(id: params[:id]).first
      if faq.destroy
        redirect_to :back
      else
        redirect_to :back
      end
    end
  end

  def faq_update
    if params[:faq_id].present?
      faq = Faq.where(id: params[:faq_id]).first
      if faq.update_attributes(params[:faq])
        redirect_to :back
      else
        redirect_to :back
      end
    end
  end

  def contact_us
    from = params[:email]
    name = params[:user_name]
    subject = params[:title]
    body = params[:description]
    Resque.enqueue(App::Background::OrganisationContactUs, params[:id], from, name, subject, body)
    redirect_to :back,:notice => "Process successful."
  end

  def edit_user_org
    @organisation = Organisation.find(params[:id])
  end  

  def update_user_org
    @organisation = Organisation.find(params[:id])
    @organisation.update_attributes(params[:organisation])
    @organisation.save  
  end
  #reactivated deactivated user  

  def deactivate_account
    @payment= Payment.find_by(id: params[:payment])
    response = JSON.parse @payment.response
    if response["object"] == "customer"
      @cus_id=response["id"]
      @sub = Subscription.find_by(id: @payment.subscription_id)
      Stripe.api_key = @sub.stripe_secret
      cu = Stripe::Customer.retrieve(@cus_id)
      cu.delete   
    end
    @payment.destroy
    current_user.delete
    redirect_to root_path
  end

  def reactivate_account
    @user=User.deleted.find_by(id: params[:id] )
    @user.restore
    redirect_to polymorphic_path([:soft_deleted_user, current_organisation, :subscriptions])
  end

  def badge_authority_details
    unless !!current_organisation.badge_authority
     current_organisation.create_badge_authority(name: current_organisation.try(:company_name), url: organisation_url(current_organisation))
    end 
    @badge_auth = current_organisation.badge_authority
  end

  def badge_authority_details_save
    @badge_auth = current_organisation.badge_authority
    if !!@badge_auth
       @badge_auth.update_attributes(params[:badge_authority])
    end
    redirect_to action: :badge_authority_details
  end




  private

  def build_dependents
    @organisation.build_address if @organisation.address.blank?
    @organisation.address.build_telephone if @organisation.address.telephone.blank?
  end
end