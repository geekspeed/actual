class SubscriptionsController < ApplicationController

	before_filter :is_admin?

	def new
		@all_subscription= current_organisation.subscriptions
	end

	def create
		@subscription= current_organisation.subscriptions.new(params[:sub_form])
		pay_keys={stripe_secret: Payment.config["secret"], stripe_public: Payment.config["publishable"], owner_id: all_super_admin.first.id}
		
		if @subscription.interval == "one_off"
			@subscription.update_attributes(pay_keys)
		else
			@subscription.update_attributes_and_create_plan!(pay_keys)
		end
		redirect_to plans_payments_path	
	end

	def edit
		@subscription= Subscription.find(params[:id])
	end

	def update
    @subscription = Subscription.find(params[:id])
    if @subscription.update_attributes(params[:subscription])
    	flash[:notice] = 'subscription was successfully created.'
      redirect_to subscriptions_payments_path
    else
      redirect_to :back	
    end
	end

	def soft_deleted_user
    @deleted_users = User.deleted    
  end


	private

  def is_admin?
    if !current_user.company_admin?(current_organisation)
      redirect_to root_path
    end
  end
	
end
