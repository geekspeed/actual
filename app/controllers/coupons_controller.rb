class CouponsController < ApplicationController
  before_filter :is_admin?

  def index
    @all_coupons = current_organisation.coupons
    
  end

  
  def show
   
  end

  def new
    
  end

  def create
    # Amount in cents
    @coupons = current_organisation.coupons.new(params[:coupon])
   
    if @coupons.save_and_create_coupons!
      flash[:notice] = "Charged successfully"
      redirect_to :back
    else
      flash[:error] = "There are errors: #{@coupons.error}"
      redirect_to :back
    end
  end
  private

  def is_admin?
    if !current_user.company_admin?(current_organisation)
      redirect_to root_path
    end
  end
end