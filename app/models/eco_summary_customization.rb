class EcoSummaryCustomization
  include Mongoid::Document
  include Mongoid::Timestamps
   
  field :ecosystem_navbar_homepage, :type => Boolean, :default => true
  field :company_name_navbar_configurable, :type => Boolean, :default => true
  field :programs,  :type => Boolean, :default => true
  field :eco_plan,  :type => Boolean, :default => true
  field :goal,  :type => Boolean, :default => true
  field :entry_criteria,  :type => Boolean, :default => true
  field :twitter_handle,  :type => Boolean, :default => true
  field :facebook_url,  :type => Boolean, :default => true
  field :linkedin_url,  :type => Boolean, :default => true
  field :welcome_message,  :type => Boolean, :default => true
  field :terms,  :type => Boolean, :default => true
  field :partners,  :type => Boolean, :default => true
  field :quotes,  :type => Boolean, :default => true
  field :freeform,  :type => Boolean, :default => true
  field :casestudy,  :type => Boolean, :default => true
  field :privacy_policy, :type => Boolean, :default => true
  field :blog, :type => Boolean, :default => false

  belongs_to :eco_summary
end
