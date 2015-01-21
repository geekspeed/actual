class Coupon
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  belongs_to :subscription
  belongs_to :organisation

  field :percent_off,   type: Integer,   default: 0
  field :total_coupons,  type: Integer,  default: 0
  field :used_coupons, type: Integer,  default: 0
  def save_and_create_coupons!
    if save
      create_coupons!
    else
      false
    end
  end

  def stripe_params(options = {})
    as_json({ only: [:percent_off] }).merge(
      {"duration" => "forever", "id" => id})
  end

  def create_coupons!(override = {})
     Stripe.api_key = subscription.stripe_secret #self.class.config["secret"]
    # Create the charge on Stripe's servers - this will charge the user's card
      coupon = Stripe::Coupon.create(stripe_params.merge(override))
      update_attributes({success: true, response: coupon.to_json})
      true
  end
  
end
