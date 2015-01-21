class ProgramInvitation
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :format_input
  after_save :deliver_invitation

  field :invited_participants,  :type => Array
  field :invited_selectors,     :type => Array
  field :invited_panellists,    :type => Array
  field :invited_mentors,       :type => Array
  field :invited_program_admins,       :type => Array
  field :invited_people,       :type => Array
  field :people_role,       :type => String

  belongs_to :program
  belongs_to :invited_by, :class_name => "User"

  has_one :program_invitation_mail

  def format_input
    self["invited_participants"] = self["invited_participants"]
    .split(",").collect(&:strip) if self["invited_participants"]
    .present?
    self["invited_selectors"] = self["invited_selectors"]
    .split(",").collect(&:strip) if self["invited_selectors"].present?
    self["invited_panellists"] = self["invited_panellists"]
    .split(",").collect(&:strip) if self["invited_panellists"].present?
    self["invited_mentors"] = self["invited_mentors"].split(",")
    .collect(&:strip) if self["invited_mentors"].present?
    self["invited_program_admins"] = self["invited_program_admins"].split(",")
    .collect(&:strip) if self["invited_program_admins"].present?
    self["invited_people"] = self["invited_people"].split(",")
    .collect(&:strip) if self["invited_peopl"].present?
  end

  def deliver_invitation
    
  end
end