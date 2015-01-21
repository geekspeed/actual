class Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,          type: String,   default: ""
  field :description,   type: String,   default: ""
  field :duration,      type: Integer,  default: 0 #-99 means indefinite
  field :currency_code, type: String,   default: "USD"
  field :amount,        type: Integer,  default: 0
  field :quantity,      type: Integer,  default: 0
  field :stripe_secret, type: String
  field :stripe_public, type: String
  field :plan_type,     type: String
  field :interval,      type: String

  belongs_to :organisation
  belongs_to :entity,   polymorphic: true
  belongs_to :owner, class_name: "User"

  has_many :coupons, :dependent => :destroy

  scope :by, lambda{|owner| where(owner: owner)}
  scope :for,lambda{|entity| where(entity: entity) }
  scope :type, lambda{|plan| where(plan_type: plan)}

  def to_s
    name
  end

  def amount_formatted
    [ISO4217::Currency.from_code(currency_code).try(:symbol), amount].compact.join(" ")
  end

  def update_attributes_and_create_plan!(pay_keys)
    if update_attributes(pay_keys)
      create_plan!
    else
      false
    end
  end

  def stripe_params(options = {})
    as_json({ only: [:interval, :name] }).merge(
      {"currency" => currency_code, "id" => id, "amount" => amount*100})
  end

  def create_plan!(override = {})
     Stripe.api_key = stripe_secret #self.class.config["secret"]
    # Create the charge on Stripe's servers - this will charge the user's card
      plan = Stripe::Plan.create(stripe_params.merge(override))
      update_attributes({success: true, response: plan.to_json})
      true
  end
end
