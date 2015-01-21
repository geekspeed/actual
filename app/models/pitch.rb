class Pitch
  include Mongoid::Document
  include Mongoid::Timestamps
  include App::Workflows::PitchHook
  include Sunspot::Mongoid2
  after_save :reindex_pitches
  before_destroy :reindex_pitches
  before_update :check_changes
  after_destroy :delete_pitch_phase
  searchable do
    text :title
    string :program_id
    text :summary do 
      summary.try(:content)
    end
    text :summary_history do 
      if !summary.try(:history_tracks).blank?
        summary.history_tracks.map{ |p| [p.modified.values, p.original.values]}.flatten.uniq
      end
    end
    text :members do 
      User.where(:id.in =>members).map{ |p| [p.full_name]}
    end
    text :mentors do 
      User.where(:id.in =>mentors).map{ |p| [p.full_name]}
    end
    text :user do 
      user.try(:full_name)
    end
    text :tags do 
      tags
    end
    text :organisation do 
      Organisation.where(:id => organisation).map{ |p| [p.company_name, p.description, p.industry, p.type, p.type_of]}
    end
  end
  
  attr_protected :skills 

  belongs_to :program
  belongs_to :user

  scope :pitch_for, lambda{|user| where(:user_id => user.id.to_s)}
  field :organisation, :type => String
  field :title,         :type => String
  mount_uploader :avatar, AvatarUploader

  field :tags,          :type => Array, :default => []
  field :public,        :type => Boolean, default: true

  field :contacts,      :type => Array, :default => []
  field :membership_requesters,       :type => Array, :default => []
  field :collaborate_requesters,       :type => Array, :default => []
  field :collaboraters,      :type => Array, :default => []
  field :mentors,       :type => Array, :default => []
  field :members,       :type => Array, :default => []
  field :closed,        :type => Boolean, :default => false
  field :skills,        :type => Array, :default => []
  field :rating,        :type => Float, :default => 0
  field :points,        :type => Float, :default => 0
  field :stop_editing,  :type => Boolean, :default => true
  field :joined_team_members,       :type => Hash, :default => {}
  field :joined_team_mentors,       :type => Hash, :default => {}

  has_one :summary,                 :class_name => "PitchSummary", :dependent => :destroy
  accepts_nested_attributes_for :summary, :reject_if => :all_blank

  has_many :pitch_due_diligence_matrices, :dependent => :destroy
  has_many :due_diligence_posts, :dependent => :destroy

  has_many :documents,              :class_name => "PitchDocument", :dependent => :destroy
  has_many :milestones, :dependent => :destroy
  has_many :feedbacks,      :class_name => "PitchFeedback", :dependent => :destroy
  has_many :custom_feedbacks, :class_name => "PitchCustomFeedback", :dependent => :destroy
  has_many :custom_iterations, :class_name => "PitchCustomIteration", :dependent => :destroy
  has_many :invitations, :class_name => "PitchInvitation", :dependent => :destroy
  belongs_to :pitch_branch
  has_many :activity_performances, :dependent => :destroy
  has_many :collaborater_requests, :class_name => "PitchCollaboratorRequest", :dependent => :destroy
  
  has_many :pitch_privacies, :class_name => "PitchPrivacy", :dependent => :destroy
  
  has_many :pitch_ratings, :dependent => :destroy
  
  has_many :tasks, :dependent => :destroy

  has_many :custom_events, :dependent => :destroy
  
  validates :title, :presence => true

  before_destroy :delete_project_feed, :delete_pitch_phases
  after_create :build_general_milestone 

  delegate :workflows, :active_phases, to: :program

  def invite_members(members = [])
    members.each do |params|
      invite_member!(params)
    end
  end

  def invite_member!(params = {})
    user_reg = User.where(email: params[:email]).first
    if user_reg
      user = User.invite!({email: user_reg.try(:email), first_name: 
        user_reg.try(:first_name) , last_name: user_reg.try(:last_name) })  do |u|
        u.skip_invitation = true
      end
    else
      user = User.invite!({email: params[:email], first_name: 
        params[:first_name], last_name: params[:last_name] })  do |u|
        u.skip_invitation = true
      end
    end
    user.send(:generate_invitation_token) && user.save(:validate => false) if user.invitation_token.blank?
    user.invite_role("participant", program_id.to_s)
    #background IT
    
    Resque.enqueue(App::Background::InviteMember, user.id, program_id, program.class.to_s, self.id)

  end

  def invite_mentor(mentor_id, invited_by_id)
    user = User.find_by(id: mentor_id)
    invitations.where(invitee_id: user.id, invitee_type: "mentor").delete
    invitation = invitations.create(program_id: program_id, invited_by_id: invited_by_id, invitee_id: mentor_id, invitee_type: "mentor", status: "pending")
    Resque.enqueue(App::Background::InviteMentor, user.id, program_id, program.class.to_s, self.id, invitation.id)
  end

  def add_to_skills!(skill)
    add_to!(:skills, skill)
  end

  def remove_from_skills!(skill)
    remove_from!(:skills, skill)
  end

  def add_to_contacts!(user_id)
    add_to!(:contacts, user_id)
  end

  def add_to_membership_requesters!(user_id)
    add_to!(:membership_requesters, user_id)
  end

  def add_to_collaborater_requesters!(user_id)
    add_to!(:collaborate_requesters, user_id)
  end

  def add_to_mentors!(user_id)
    add_to!(:mentors, user_id)
    found_mentors!
  end

  def add_to_members!(user_id)
    add_to!(:members, user_id)
  end

  def add_to_collaboraters!(user_id)
    add_to!(:collaboraters, user_id)
  end

  def remove_from_contacts!(user_id)
    remove_from!(:contacts, user_id)
  end

  def remove_from_membership_requesters!(user_id)
    remove_from!(:membership_requesters, user_id)
  end

  def remove_from_collaborater_requesters!(user_id)
    remove_from!(:collaborate_requesters, user_id)
  end

  def remove_from_mentors!(user_id)
    remove_from!(:mentors, user_id)
  end

  def remove_from_members!(user_id)
    remove_from!(:members, user_id)
  end

  def remove_from_collaboraters!(user_id)
    remove_from!(:collaboraters, user_id)
  end

  def mentor?(user_id)
    user_id = user_id.respond_to?(:id) ? user_id.id.to_s : user_id
    mentors.include?(user_id)
  end

  def member?(user_id)
    user_id = user_id.respond_to?(:id) ? user_id.id.to_s : user_id
    members.include?(user_id)
  end

  def collaborater?(user_id)
    user_id = user_id.respond_to?(:id) ? user_id.id.to_s : user_id
    collaboraters.include?(user_id)
  end

  def owner?(user_id)
    user_id.is_a?(User) ? user == user_id : user.id.to_s == user_id
  end

  def team?(user_id)
    owner?(user_id) || member?(user_id) || collaborater?(user_id)
  end

  def team_and_mentor?(user_id)
    team?(user_id) || mentor?(user_id)
  end

  def team_and_mentor_both?(user_id)
    team?(user_id) && mentor?(user_id)
  end

  def team
    [user_id, members, mentors, collaboraters].flatten.uniq
  end

  def team_without_coll
    [user_id, members, mentors].flatten.uniq
  end

  def pitch_team_and_admins
    [team,program.organisation.admins].flatten.uniq
  end

  def toggle_editing!
    update_attribute(:stop_editing, !stop_editing)
  end

  def blank_field
    private_fields = ["_id", "custom_fields", "contacts", 
      "mentors", "members","program_id", "user_id", "avatar", "updated_at", "created_at"]
    doc = as_document.delete_if{|k,v| 
      private_fields.include?(k)}
    blank_fields = doc.select{|k,v| v.blank?}
    blank_fields.keys.first
  end

  def mentor_offer(mentor,pitch,members)
    @mentor =mentor
    @pitch =pitch
    @members =members
    @members.each do |member|
      Resque.enqueue(App::Background::MentorOfferMailer,@mentor , @pitch, member) 
    end
  end

  def join_team(new_team_member,pitch,members)
    @new_team_member =new_team_member
    @pitch =pitch
    @members =members
    @members.each do |member|
      Resque.enqueue(App::Background::JoinTeamMailer,@new_team_member , @pitch, member) 
    end
  end

  def view_other_team_pitch?(user)
    program.try(:program_scope).try(:view_other_team_pitches) or team_and_mentor?(user.try(:id).to_s)
  end

  def collaborater_offer(collaborater, pitch, members, invitation_msg)
    members.each do |member|
      Resque.enqueue(App::Background::CollaborationOfferMailer, collaborater , pitch, member, invitation_msg) 
    end unless members.blank?
  end


  def phase_conditions_completed(phase)
    !workflows.where(:id.in=>phase.phase_conditions).collect{|p| p.complete?(self, by_user = nil)}.include? false
  end

  def prev_phase_completed(prev_phase)
   !prev_phase.nil? ? prev_phase.complete?(self, by_user = nil) : true
  end

  def delete_pitch_phases
    PitchPhase.where(pitch_id: self.id).destroy
  end

  private

  def add_to!(attribute, user_id)
    user_id = user_id.respond_to?(:id) ? user_id.id.to_s : user_id
    existing = send(attribute)
    existing << user_id
    update_attribute(attribute, existing)
  end

  def remove_from!(attribute, user_id)
    user_id = user_id.respond_to?(:id) ? user_id.id.to_s : user_id
    existing = send(attribute)
    existing.delete(user_id)
    update_attribute(attribute, existing)
  end

  def build_general_milestone
    self.milestones.find_or_create_by(description: "General")
  end

  def delete_project_feed
    CommunityFeed.for_pitch(self).destroy_all
  end

  def reindex_pitches
    if self.changed?
      Resque.enqueue(App::Background::SolrIndexing, self.class.to_s, self.id)
    end
  end
  
  def check_changes
    if self.members_changed?
      previous_value = self.members_was
      changed = self.members.flatten - previous_value.flatten
      changed.each do |user|
        if !joined_team_members.include?(user)
          joined_team_members[user] = Time.now
        else
          joined_team_members.delete(user)
        end
      end
    end

    if self.mentors_changed?
      previous_value = self.mentors_was
      changed = self.mentors.flatten - previous_value.flatten
      changed.each do |user|
        if !joined_team_mentors.include?(user)
          joined_team_mentors[user] = Time.now
        else
          joined_team_mentors.delete(user)
        end
      end
    end
  end

  def delete_pitch_phase
    workflows = program.workflows
    workflows.each do |workflow|
      workflow.pitch_phases.where(:pitch_id => id).destroy
    end
  end

end
