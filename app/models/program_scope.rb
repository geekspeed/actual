class ProgramScope
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :reaffirm_inputs

  #INDEXES
  index({ country: 1 }, {  background: true })

  PARTICIPANT_SCOPE = { "public" => "Open to Public", 
    "company" => "People from my company", 
    "invitees" => "Invitees Only" }
  COUNTRY = ["France", "Germany", "Italy", "Spain",
   "United Kingdom", "United States"]
  belongs_to :program

  #if not contry specific than it is global
  field :country_specific,    :type => Boolean, :default => false
  field :country,             :type => String
  field :participant_scope,   :type => String
  field :email_restriction,   :type => String

  #Manual approval for all participant applications without invitation
  field :manual_approval_for_participant,      :type => Boolean, :default => false
  #Manual approval for all mentor applications without invitation
  field :manual_approval_for_mentor,      :type => Boolean, :default => false
  #Do you want to have the ability to manually accept applicants who are not from the specified email domain
  field :approve_other_domain, :type => Boolean, :default => false
  
  field :approve_external_participants, :type => Boolean, :default => true

  ##Registration & Applications
  #People can register with social media
  field :social_registration,  :type => Boolean, :default => false
  #Can new users register throughout this program?
  field :can_always_join,      :type => Boolean, :default => false
  #Can users create multiple pitches?
  field :multiple_pitches,     :type => Boolean, :default => false
  #Stop participants from adding projects
  field :stop_adding_project_participants,     :type => Boolean, :default => false

  ##Feedback
  #Can users peer review the pitches?
  field :peer_review_active,   :type => Boolean, :default => false
  #Stop editing fields for pitches?
  field :stop_editing_fields,   :type => Boolean, :default => false
  #Automatically create a project
  field :automatically_create_project,   :type => Boolean, :default => false

  ##Privacy
  #Can teams view each other's pitches?
  field :view_other_team_pitches, :type => Boolean, :default => true
  #Should teams have the ability to set the privacy settings of their pitch to private, so other participants will not be able to see it?
  field :pitch_privacy_settings,  :type => Boolean, :default => false
  field :pitch_privacy_some_fields,  :type => Boolean, :default => false

  ##Feedback Privacy Settings
  #Private means, only visible for admins and pitch members 
  field :applicants_feedback_public,  :type => Boolean, :default => true
  field :mentors_feedback_public,     :type => Boolean, :default => true
  field :panels_feedback_public,      :type => Boolean, :default => true
  field :selectors_feedback_public,   :type => Boolean, :default => true
  field :admins_feedback_public,      :type => Boolean, :default => true

  ##On which factors do you like to tag your pitches
  field :pitch_tags,            :type => Array
  ##On which factors do you like to tag your mentors
  field :mentor_tags,           :type => Array

  ##Virtual Dollars
  #Amount of virtual Dollars for Applicants
  field :virtual_dollar_for_applicants, :type => Integer, :default => 10
  #Amount of virtual Dollars for Mentors
  field :virtual_dollar_for_mentors, :type => Integer, :default => 10
  #Number of pitches a user can back
  field :user_backed_pitches,   :type => Integer, :default => 5
  
  #For social media login options
  field :facebook, :type => Boolean, :default => true
  field :twitter, :type => Boolean, :default => true
  field :linkedin, :type => Boolean, :default => true
  
  #For people to be associated with an organisation
  field :associated_organisation, :type => Boolean, :default => false
  field :show_judging_score,      :type => Boolean, :default => true
    
  #Offer Anonymous Login Feature
  field :offer_anonymous_login,      :type => Boolean, :default => false

  protected

  def reaffirm_inputs
    self.pitch_tags   =   [] unless self.pitch_tags.is_a?(Array)
    self.mentor_tags  =   [] unless self.mentor_tags.is_a?(Array)
  end
end