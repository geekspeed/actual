class WelcomeTermsMessage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :message_for_applicant,  :type => String,  :default => ""
  field :message_for_mentor,  :type => String,  :default => ""
  field :message_for_selector,  :type => String,  :default => ""
  field :message_for_panellist,  :type => String,  :default => ""

  belongs_to :program_summary
  
end
