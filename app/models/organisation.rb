class Organisation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid2
  after_save :reindex_organisation
  before_destroy :reindex_organisation

  searchable do
    string :id
    text :company_name
    text :industry
    text :type
    text :type_of
    text :description
  end

  mount_uploader :avatar, AvatarUploader

  after_save :assign_admins
  before_create :assign_owner

  TYPES = {"enterprise" => "Enterprise", "non_profit" => 
    "Education/Government/NonProfit"}

  attr_protected :activate

  field :slogan,                :type => String, :default => ""
  field :manubar_color,         :type => String, :default => "#07B291"
  field :background_color,      :type => String, :default => "#333"
  field :type_of,               :type => String, :default => ""
  field :company_name,          :type => String, :default => ""
  field :industry,              :type => String
  field :description,           :type => String
  field :size,                  :type => String
  field :type,                  :type => String
  #stores user ids
  field :admins,                :type => Array, :default => []
  field :activate,              :type => Boolean, :default => false

  has_one :badge_authority, :dependent => :destroy

  has_one :address, :dependent => :destroy
  accepts_nested_attributes_for :address, reject_if: :all_blank

  has_many :programs, :dependent => :destroy
  has_one  :domain_map, :dependent => :destroy
  has_many :surveys, :dependent => :destroy

  has_many :subscriptions, :dependent => :destroy
  has_many :coupons, :dependent => :destroy

  belongs_to :owner, :class_name => "User"
  has_one :eco_summary, :dependent => :destroy
  has_many :faqs, :dependent => :destroy
  has_many :community_feeds, :dependent => :destroy
  accepts_nested_attributes_for :faqs, reject_if: :all_blank

  validates :company_name, :presence => true

  scope :for, lambda{ |user| where(:admins.in => [user.id.to_s]) }

  #INDEXES
  index({ company_name: 1 }, { unique: true, background: true })
  index({ admins: 1 }, { background: true })
  index({ owner: 1 }, { background: true })
  
  SIZE = [ "Less than 10 employees", "11 to 50 employees", "51 to 250 employees", "251 to 1000 employees", "1001 to 10000 employees", "10000+ employees"]
  TYPE = [ "Business", "Not for profit", "Membership organisation", "Public sector", "Local Authority", "Incubator / Innovation Cluster", "LEP"]

  def toggle_status!
    status = !activate
    update_attribute(:activate, status)
    owner.update_attribute(:approved, status)
    Resque.enqueue(App::Background::SendApprovalMessageToAdmin, owner.try(:id), id) if status
  end

  def owner?(user_id)
    owner_id == user_id
  end

  def title
    company_name
  end

  def type_of
    TYPES[read_attribute(:type_of)]
  end

  def build_invitations(mails, for_role, admin_invitor_id)
    invitations_to = mails[:company_admin].split(",").reject(&:blank?)
    invitation_message = mails[:invite_mail]
    invitations_to.each do |invitation|
      if invitation and invitation.strip.match Devise::email_regexp
        User.invite_user_admin(invitation, self, for_role, invitation_message, admin_invitor_id)
      end
    end
  end

  def add_admin!(user_id)
    admins << user_id
    save!
  end

  def to_s
    "Organisation: #{company_name}"
  end

  private 

  def assign_admins
    users = User.find(self.admins)
    RoleType.on_organisation.each do |type|
      users.each do |user|
        user.add_role(type.to_s, self.id.to_s)
      end
    end
  end

  def assign_owner
    self["owner_id"] = self["admins"].first
  end

  def reindex_organisation
    if self.changed?
      Resque.enqueue(App::Background::SolrIndexing, self.class.to_s, self.id)
    end
  end

end
