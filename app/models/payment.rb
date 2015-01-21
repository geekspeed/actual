class Payment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  before_validation :initialize_subscription

  before_save :initialize_subscription

  default_scope desc(:created_at) 
  scope :by, lambda{|customer| 
    where(customer_id: customer.id, customer_type: customer.class.to_s)
  }
  scope :for, lambda{|entity| 
    where(entity_id: entity.id, entity_type: entity.class.to_s)
  }
  scope :success, where(success: true)
  scope :running, where(:start_date.lte => Date.today, :end_date.gte => Date.today)

  belongs_to :customer, polymorphic: true
  belongs_to :entity,   polymorphic: true
  belongs_to :subscription

  field :amount,      type: Integer,  default: 0
  field :currency,    type: String,   default: "usd"
  field :card,        type: String,   default: ""
  field :description, type: String,   default: ""
  field :success,     type: Boolean,  default: false
  field :error,       type: String
  field :response,    type: String
  field :start_date,  type: Date,     default: Date.today
  field :end_date,    type: Date,     default: Date.today
  field :coordinates, type: Array
  field :ip_address,  type: String
  field :country,     type: String
  field :vat,         type: Integer
  field :vat_number,  type: String
  field :coupon,      type: String
  geocoded_by :ip_address
  reverse_geocoded_by :coordinates do |obj,results|
    if geo = results.first
      obj.country = geo.country
    end
  end
  after_validation :geocode, :reverse_geocode

  def self.paid?(entity, user)
    !!by(user).for(entity).success.running.first
  end

  def stripe_params(options = {})
    as_json({ only: [:card, :currency, :description] }).merge(
      {"amount" => amount + vat.to_i})
  end

  def calculate_vat
    eligible_for_vat? ? (amount * 0.20).ceil : 0
  end

  def eligible_for_vat?
    !!Eurovat.must_charge_vat?(country, vat_number)
  end

  def calculate_vat
    eligible_for_vat? ? (amount * 0.20).ceil : 0
  end

  def eligible_for_vat?
    !!Eurovat.must_charge_vat?(country, vat_number)
  end

  def calculate_vat
    eligible_for_vat? ? (amount * 0.20).ceil : 0
  end

  def eligible_for_vat?
    !!Eurovat.must_charge_vat?(country, vat_number)
  end

  def calculate_vat
    eligible_for_vat? ? (amount * 0.20).ceil : 0
  end

  def eligible_for_vat?
    !!Eurovat.must_charge_vat?(country, vat_number)
  end

  def save_and_charge!
    if save
      charge!
    else
      false
    end
  end

  def amount_formatted
    Payment.currency_formatted(currency, amount/100)
    # [ISO4217::Currency.from_code(currency).try(:symbol), amount/100].compact.join(" ")
  end

  def vat_formatted
    Payment.currency_formatted(currency, vat/100)
    # [ISO4217::Currency.from_code(currency).try(:symbol), vat/100].compact.join(" ")
  end

  def self.currency_formatted(currency_code, amount)
    [ISO4217::Currency.from_code(currency_code).try(:symbol), amount].compact.join(" ")
  end

  def self.config
    conf = YAML.load_file("#{Rails.root}/config/stripe.yml")[Rails.env]
  end

  def expired?
    return false if end_date < start_date
    Date.today > end_date
  end

  def due?
    (end_date - Date.today).to_i <= 5 
  end

  def self.current_subscription(customer, entity = nil)
    sub = Payment.success.running.by(customer)
    sub = sub.for(entity) if entity
    sub.first
  end

  def self.last_subscription(customer, entity)
    Payment.success.by(customer).for(entity).first
  end

  def current_subscription
    scop = Payment.success.running
    scop = scop.by(customer) if customer
    scop = scop.for(entity) if entity
    scop.first
  end

  def last_subscription
    scop = Payment.success
    scop = scop.by(customer) if customer
    scop = scop.for(entity) if entity
    scop.first
  end

  private

  def initialize_subscription
    raise "Subscription required" and return if !subscription_id
    self.amount = subscription.amount * 100
    self.currency = subscription.currency_code
    self.description = subscription.description
    subscription_period
  end

  def subscription_period
    if !!last_subscription && last_subscription.start_date > Date.today
      self.start_date = last_subscription.end_date.next
      self.end_date = self.start_date + subscription.duration.days
    elsif current_subscription
      self.start_date = current_subscription.end_date.next
      self.end_date = self.start_date + subscription.duration.days
    else
      self.start_date = Date.today
      self.end_date = Date.today + subscription.duration.days
    end
  end

  def subscription_period
    if current_subscription
      self.start_date = current_subscription.end_date.next
      self.end_date = self.start_date + subscription.duration.days
    else
      self.start_date = Date.today
      self.end_date = Date.today + subscription.duration.days
    end
  end

  def subscription_period
    if current_subscription
      self.start_date = current_subscription.end_date.next
      self.end_date = self.start_date + subscription.duration.days
    else
      self.start_date = Date.today
      self.end_date = Date.today + subscription.duration.days
    end
  end

  def subscription_period
    if current_subscription
      self.start_date = current_subscription.end_date.next
      self.end_date = self.start_date + subscription.duration.days
    else
      self.start_date = Date.today
      self.end_date = Date.today + subscription.duration.days
    end
  end

  def charge!(override = {})
    Stripe.api_key = subscription.stripe_secret #self.class.config["secret"]

    # Create the charge on Stripe's servers - this will charge the user's card
    begin
      #card_token = Stripe::Token.create( :card => { :name => params[:account][:name_on_card], :number => params[:account][:card_number], :exp_month => params[:exp_month], :exp_year => params[:exp_year], :cvc => params[:account][:card_id] })
      if interval == "one_off"
        charge = Stripe::Charge.create(stripe_params.merge(override))
        update_attributes({success: true, response:  charge.to_json})
      else
        customer_params = {:card => card, :plan =>  subscription_id, :email => email}
        (customer_params[:coupon] = coupon) if !coupon.blank?
        stripe_customer = Stripe::Customer.create(customer_params)
        update_attributes({success: true, response:  stripe_customer.to_json})
        if stripe_customer["discount"]
          coupon=Coupon.find_by(id: stripe_customer["discount"]["coupon"]["id"])
          coupon.update_attributes(used_coupons: coupon.used_coupons+1)
        end
      end
      
      true
    rescue Stripe::CardError => e
      update_attributes({success: false, error: e.message })
      # The card has been declined
      false
    end
  end

end
