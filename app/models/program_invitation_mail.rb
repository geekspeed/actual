class ProgramInvitationMail
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program_invitation

  field :applicant_message, :type => Array
  field :selectors_message, :type => Array
  field :panel_message, :type => Array
  field :mentors_message, :type => Array
  field :program_admins_message, :type => Array
  field :role_type, :type => String
end
