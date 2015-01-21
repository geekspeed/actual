class PaymentsController < ApplicationController

  skip_before_filter :ensure_paid

  def index
    @payments = current_user.super_admin? ? Payment.all : Payment.by(current_user)
  end

  def plans
    @subscription = Subscription.find(params[:sub]) if params[:sub]
    selected_product_ids = context_program.selected_product_list.reject(&:blank?)
    selected_products = current_organisation.subscriptions.in(id: selected_product_ids)
    @subscriptions = selected_products.present? ? selected_products : Subscription.type("organisation")
  end

  def subscriptions
    @subscriptions = Payment.success.running.by(current_user)
    redirect_to action: :plans and return if @subscriptions.count.zero?
  end

  def show
    @subscription = Payment.current_subscription(current_user)
  end

  def new
    @subscription = Subscription.find(params[:sub]) if params[:sub]
    @payment = Payment.new(subscription: @subscription, ip_address: request.ip)
    @payment.valid?
  end

  def edit
    @subscription = Subscription.find(params[:sub]) if params[:sub]
    @payment = Payment.find(params[:id])
    @payment.valid?
  end

  def create
    # Amount in cents
    @payment = Payment.new(
      { customer: current_user,
        email: current_user.email,
        card: params[:stripeToken],
        description: "By #{current_user.email}"
      }.merge(params[:payment])
    )
    if @payment.save_and_charge!
      flash[:notice] = "Charged successfully"
      redirect_to root_url
    else
      flash[:error] = "There are errors: #{@payment.error}"
      redirect_to :back
    end
  end

  def update
    begin
      payment = Payment.find(params[:id])
      payment.update_attributes({ customer: current_user,
          email: current_user.email,
          card: params[:stripeToken],
          description: "By #{current_user.email}"
        }.merge(params[:payment]))
      customer = Stripe::Customer.retrieve(JSON.parse(payment.response)["id"])
      customer.card = params[:stripeToken]
      customer.save
      flash[:notice] = "Card successfully Updated"
      redirect_to root_url
    rescue Exception => e
      flash[:error] = "There are errors: #{e.message}"
      redirect_to :back
    end
  end

  def check_vat
    response = Eurovat.must_charge_vat?(Geocoder.search(request.ip).first.data["country_name"], 
      params[:vat_number]) rescue false
    render json: { status: "ok", valid_vat: response }
  end 

end
