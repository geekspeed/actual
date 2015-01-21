class ProgramSummaryCustomization
  include Mongoid::Document
  include Mongoid::Timestamps

  field :program_plan,  :type => Boolean, :default => true
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
  field :freeform_html_1, :type => Boolean, :default => true
  field :freeform_html_2, :type => Boolean, :default => true
  field :freeform_html_3, :type => Boolean, :default => true

  belongs_to :program_summary
end
