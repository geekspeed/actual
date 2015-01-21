class EcoSummary
  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :avatar, AvatarUploader
  mount_uploader :lifestyle_background, LifestyleUploader
  
  before_save :reaffirm_inputs
  has_many :eco_plans, :dependent => :destroy
  has_many :eco_partners, :dependent => :destroy
  has_many :eco_quotes, :dependent => :destroy
  has_many :eco_case_studies, :dependent => :destroy
  has_one :eco_summary_customization, :dependent => :destroy
  has_one :eco_summary_order, :dependent => :destroy
  has_many :eco_free_forms, :dependent => :destroy
  
  accepts_nested_attributes_for :eco_plans, reject_if: :all_blank
  accepts_nested_attributes_for :eco_partners, reject_if: :all_blank
  accepts_nested_attributes_for :eco_case_studies, reject_if: :all_blank
  accepts_nested_attributes_for :eco_free_forms, reject_if: :all_blank
  accepts_nested_attributes_for :eco_quotes, reject_if: :all_blank
  accepts_nested_attributes_for :eco_summary_customization, reject_if: :all_blank
  accepts_nested_attributes_for :eco_summary_order, reject_if: :all_blank

  belongs_to :organisation

  field :overview,        :type => String
  field :goal,            :type => String
  field :welcome_message, :type => String
  field :entry_criteria,  :type => Array
  field :terms,           :type => String
  field :terms_to_footer, :type => Boolean, :default => false
  field :twitter_url,     :type => String
  field :facebook_url,    :type => String
  field :linkedin_url,    :type => String
  field :case_study_title, :type => String, :default => ""
  field :privacy_policy,  :type => String
  field :join_ecosystem_button, :type => String, :default => ""
  field :ecosystem_name, :type => String, :default => ""

  field :eco_free_form_public,     :type => Boolean, :default => true
  field :eco_plan_public,     :type => Boolean, :default => true
  field :visible_to_participants,  :type => Boolean, :default => false

  validates :twitter_url, :url => {:allow_blank => true}
  validates :facebook_url, :url => {:allow_blank => true}
  validates :linkedin_url, :url => {:allow_blank => true}

  protected

  def reaffirm_inputs
    self.entry_criteria =      [] unless self.entry_criteria.is_a?(Array)
  end
end