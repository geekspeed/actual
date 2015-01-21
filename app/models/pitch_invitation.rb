class PitchInvitation
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :pitch
  belongs_to :program
  belongs_to :invited_by, class_name: 'User', foreign_key: 'invited_by_id'

  field :invited_by_id, :type => String, :default => ""
  field :invitee_id, :type => String, :default => ""
  field :invitee_type, :type => String, :default => ""
  field :status, :type => String, :default => ""
  
  validates :pitch_id, uniqueness: { scope: [:invitee_id, :invitee_type]}
  
end