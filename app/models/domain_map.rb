class DomainMap
  require "resolv"
  include Mongoid::Document
  field :domain,                          type: String
  field :map_type,                        type: String
  field :verified,                        type: Boolean, :default => false
  field :analytics_id,                    type: String
  field :eventbrite_app_key,              type: String
  field :eventbrite_oauth_client_secret,  type: String
  belongs_to :organisation
  belongs_to :program
  belongs_to :user
  validates :domain, :presence => true
  validates_format_of :domain, :without => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
  validates_uniqueness_of :domain
  validates_uniqueness_of :organisation_id, :allow_blank => true
  validates_uniqueness_of :program_id, :allow_blank => true, :allow_nil => true
  validate :super_admin_url

  def super_admin_url
    if self.domain == "apptual.com" || self.domain == "www.apptual.com"
      errors.add(:base, "Please choose a domain other than Apptual e.g. yourwebsite.com")
    end
  end
  
  def validate?(request)
    self.verified = get_ip == get_server_ip(request)
  end

  private

  def get_ip
    Resolv.getaddress self.domain
  end

  def get_server_ip(request)
    Resolv.getaddress request.host
  end
end
