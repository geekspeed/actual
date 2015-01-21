class ProgramSummary
  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :avatar, AvatarUploader
  mount_uploader :lifestyle_background, LifestyleUploader

  before_save :reaffirm_inputs
  has_many :program_plans, :dependent => :destroy
  has_many :program_partners, :dependent => :destroy
  has_many :program_quotes, :dependent => :destroy
  has_many :case_studies, :dependent => :destroy
  has_one :program_summary_customization, :dependent => :destroy
  has_one :program_summary_order, :dependent => :destroy
  has_many :program_free_forms, :dependent => :destroy
  has_one :summary_welcome_message, class_name: 'WelcomeMessage', :dependent => :destroy
  has_one :summary_terms_message, class_name: 'WelcomeTermsMessage', :dependent => :destroy

  accepts_nested_attributes_for :program_plans, reject_if: :all_blank
  accepts_nested_attributes_for :program_partners, reject_if: :all_blank
  accepts_nested_attributes_for :case_studies, reject_if: :all_blank
  accepts_nested_attributes_for :program_free_forms, reject_if: :all_blank
  accepts_nested_attributes_for :program_quotes, reject_if: :all_blank
  accepts_nested_attributes_for :program_summary_customization, reject_if: :all_blank
  accepts_nested_attributes_for :program_summary_order, reject_if: :all_blank
  accepts_nested_attributes_for :summary_welcome_message, reject_if: :all_blank
  accepts_nested_attributes_for :summary_terms_message, reject_if: :all_blank

  belongs_to :program

  field :overview,        :type => String
  field :goal,            :type => String
  field :welcome_message, :type => String
  field :entry_criteria,  :type => Array
  field :terms,           :type => String
  field :terms_to_footer, :type => Boolean, :default => false
  field :twitter_url,     :type => String
  field :facebook_url,    :type => String
  field :linkedin_url,    :type => String
  field :eventbrite_user_keys,       :type => Array, :default => []
  field :case_study_title, :type => String, :default => ""
  field :privacy_policy,  :type => String
  field :background_opacity,  :type => String, :default => "FFFFFF"
  field :opacity_color,  :type => String, :default => "0"
  field :overlay_pattern, :type => Boolean, :default => true
  field :program_free_form_public,     :type => Boolean, :default => true
  field :program_plan_public,     :type => Boolean, :default => true

  validates :twitter_url, :url => {:allow_blank => true}
  validates :facebook_url, :url => {:allow_blank => true}
  validates :linkedin_url, :url => {:allow_blank => true}

  # validates :twitter_url,   :uri => { format: URI_FORMAT }#, :if => Proc.new{|a| a.twitter_url.present? }
  # validates :facebook_url, :uri => { format: URI_FORMAT }#, :if => Proc.new{|a| a.facebook_url.present? }
  # validates :linkedin_url, :uri => { format: URI_FORMAT }#, :if => Proc.new{|a| a.linkedin_url.present? }

  def add_to_keys!(token, email)
    existing_keys = send(:eventbrite_user_keys)
    already_added = existing_keys.select{|k| k["email"] == email}
    existing_keys = existing_keys - already_added
    existing_keys << {"token" => token, "email" => email}
    update_attribute(:eventbrite_user_keys, existing_keys)
  end

  protected

  def reaffirm_inputs
    self.entry_criteria =      [] unless self.entry_criteria.is_a?(Array)
  end
end
