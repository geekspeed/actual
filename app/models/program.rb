class Program
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :reaffirm_inputs
  after_create :master_settings, :default_workflow, :create_default_targets
  after_destroy :remove_all_user_access

  TYPE_OF_PROGRAM = ["METRIC DRIVEN", "LIGHT TOUCH"]
  TYPE_OF_BOOLEAN = ["Yes", "No", "Not Sure"]

  belongs_to :program_type
  belongs_to :organisation
  belongs_to :ecosystem
  has_one :domain_map, :dependent => :destroy
  has_one :program_summary, :dependent => :destroy
  has_one :program_scope, :dependent => :destroy
  has_one :program_invitation, :dependent => :destroy
  has_one :due_diligence_matrix, :dependent => :destroy
  has_many :pitches, :dependent => :destroy
  has_one :progress_task_manager, :dependent => :destroy
  has_many :customize_admin_emails, :dependent => :destroy
  has_many :faqs, :dependent => :destroy
  has_many :context_messages, :dependent => :destroy
  has_many :program_events, :dependent => :destroy
  accepts_nested_attributes_for :faqs, reject_if: :all_blank
  accepts_nested_attributes_for :program_events, reject_if: :all_blank

  has_many :workflows, :dependent => :destroy
  has_many :pitch_branches, :dependent => :destroy
  has_many :activity_feeds, :dependent => :destroy
  has_one :visited_faq_program, :dependent => :destroy
  has_many :basic_field_toggles, :dependent => :destroy
  has_many :help_contents, :dependent => :destroy
  has_one :course, :dependent => :destroy
  has_one :course_setting, :dependent => :destroy
  has_many :reportings, :dependent => :destroy
  has_one :program_report_branding, :dependent => :destroy
  has_many :surveys, :dependent => :destroy
  has_many :program_nav_links, :dependent => :destroy
  has_one :workspace, :dependent => :destroy
  has_one :mail_scheduling, :dependent => :destroy
  has_many :visited_notifications, :dependent => :destroy
  has_many :targettings, :dependent => :destroy
  has_many :community_feeds, :dependent => :destroy
  has_many :custom_events, :dependent => :destroy
  has_many :custom_reminders, :dependent => :destroy
  has_many :custom_reports, :dependent => :destroy
  has_many :custom_filters, :dependent => :destroy
  has_many :app_badges, :dependent => :destroy
  has_many :badge_rules, :dependent => :destroy

  #INDEXES
  index({ title: 1 }, {  background: true })
  index({ type_of_program: 1 }, { background: true })

  delegate :avatar, :to => :program_summary
  delegate :pitch_for, :to => :pitches

  field :title,                   :type => String
  field :type_of_program,         :type => String

  #What type of roles will form a part of your program?
  field :mentor_allowed,          :type => Boolean, :default => true
  field :penallist_allowed,       :type => Boolean, :default => true
  field :selectors_allowed,       :type => Boolean, :default => true

  #Role of mentoring
  field :can_mentors_post_pitch,      :type => Boolean, :default => true
  field :system_match_allowed,        :type => Boolean, :default => true
  field :courses_part_of_program,     :type => Boolean, :default => false
  field :program_part_of_ecosystem,   :type => Boolean, :default => true
  field :show_events,                 :type => Boolean, :default => false
  field :can_log_session,             :type => Boolean, :default => false

  #Group behaviour management
  field :virtual_currency,        :type => Boolean, :default => true
  field :track_incentivise,       :type => Boolean, :default => true
  field :social_share,            :type => Boolean, :default => true
  field :collaboration_request,   :type => Boolean, :default => false
  field :restrict_team_management, :type => Boolean, :default => false

  #Managing candidates that do not make it from one phase to another i.e. general to shortlist / shortlist to finallist
  field :delete_not_selected,     :type => Boolean, :default => true
  field :option_keep_data,        :type => Boolean, :default => false
  field :not_selected_can_continue, :type => Boolean, :default => false
  field :virtual_mentoring,       :type => Boolean, :default => false
  field :peer_to_peer_support,    :type => Boolean, :default => false

  # Program Payment settings
  field :is_paid,                 :type => Boolean, :default => true
  field :is_manualy_paid,         :type => Boolean, :default => false
  field :selected_product_list,   :type => Array,   :default => []

  #Engagement Calculator
  field :resource_funding,        :type => Array,   :default => []
  field :enough_resource_funding, :type => String

  field :likelihood_of_success,   :type => Array,   :default => []
  field :enough_likelihood_of_success, :type => String

  field :resource_mentoring,      :type => Array,   :default => []
  field :enough_resource_mentoring, :type => String
  field :match_pitches_for_participants, :type => Boolean, :default => false

  field :master_program,          :type => Boolean, :default => false
  field :can_rate_events,  :type => Boolean, :default => false

  ##HIDDEN FIELDS
  field :_admins, :type => Array

  validates :title, :type_of_program, :presence => true

  # default_scope where(master_program: false)

  scope :master_for, lambda{|organisation| 
    where(:organisation_id => organisation, 
      :master_program => true)
  }

  scope :regular, where(master_program: false)

  def active_phases
    workflows.active
  end

  def roles_allowed
    program_roles = RoleType.on_programs
    restricted_role = []
    restricted_role << RoleType.find_by(code: "mentor") unless mentor_allowed
    restricted_role << RoleType.find_by(code: "panellist") unless penallist_allowed
    restricted_role << RoleType.find_by(code: "selector") unless selectors_allowed
    restricted_role << RoleType.find_by(code: "awaiting_participant")
    restricted_role << RoleType.find_by(code: "awaiting_mentor")
    
    program_roles - restricted_role
  end

  def pitched_completed_phase phase
    pitch_phases = workflows.where(:code.in => [phase]).first.try(:pitch_phases)
    unless pitch_phases.blank?
      phases= pitch_phases.where(:pitch_id.in => pitches.map(&:id))
      unless phases.blank?
        return pitches.where(:id.in => phases.map(&:pitch_id))
      else
        return []
      end
    else
      return []
    end
  end

  def event_sessions
    EventSession.in(program_event_id: program_events.map(&:id))
  end

  def program_members_and_admins
    (program_members << organisation.admins).flatten
  end

  def program_members
    members = []
    RoleType.all.each do |rt|
      users = User.in("_#{rt.code}" => self.id.to_s)
      users.all.each do |user|
        members << user.id
      end
    end
    return members
  end

  def self.to_csv(user_ids)
    users = User.in(:id => user_ids)
    CSV.generate do |csv|
      csv << ["Sno.", "First Name", "Last Name", "Email"]
      index = 0
      users.each do |user|
        index += 1
        csv << [index, user.first_name, user.last_name, user.email] if user
      end
    end
  end
   
  protected

  def reaffirm_inputs
    self.resource_funding =      [] unless self.resource_funding.is_a?(Array)
    self.likelihood_of_success = [] unless self.likelihood_of_success.is_a?(Array)
    self.resource_mentoring =    [] unless self.resource_mentoring.is_a?(Array)
  end

  def default_workflow
    if organisation && self.class.master_for(organisation).first.present? && !self.master_program?
      cloner = App::Cloner::Base.new(organisation, self)
      cloner.clone!
    else
      Workflow.default_workflow_for(self)
    end
  end

  def master_settings
    return if !self.master_program?
    MasterSetting.find_or_create_by(program_id: self.id)
  end

  def remove_all_user_access
    idz = self.id.to_s
    User.selectors(idz).each do |user|
      user.remove_role("selector", idz)
    end
    User.invited_selectors(self.id.to_s).each do |user|
      user.remove_invite_role("selector", idz)
    end
    User.panellists(self.id.to_s).each do |user|
      user.remove_role("panellist", idz)
    end
    User.invited_panellists(self.id.to_s).each do |user|
      user.remove_invite_role("panellist", idz)
    end
    User.mentors(self.id.to_s).each do |user|
      user.remove_role("mentor", idz)
    end
    User.invited_mentors(self.id.to_s).each do |user|
      user.remove_invite_role("mentor", idz)
    end
    User.participants(self.id.to_s).each do |user|
      user.remove_role("participant", idz)
    end
    User.invited_participants(self.id.to_s).each do |user|
      user.remove_invite_role("participant", idz)
    end
  end
  
  def create_default_targets
    Targetting.create_default_targets(self.id)
  end
  
  def self.find_pitches(all_pitches, context_program, custom_filter, user)
      matched = false
      custom_filter.custom_rules.each do |rule|
        if !matched
          event = ProgramEvent.find(rule.event_for.to_s)
          if rule.role == "Participated In"
            matched = event.event_sessions.map(&:event_records).flatten.map(&:user).map(&:id).map(&:to_s).include?(user.id.to_s)
          else
            matched = !event.event_sessions.map(&:event_records).flatten.map(&:user).map(&:id).map(&:to_s).include?(user.id.to_s)
          end
          if matched
            if rule.field_name == "Tag"
              all_pitches = (all_pitches & all_pitches.in(:tags => rule.field_value))
            else
              code = Pitch.custom_fields.where(:id => rule.field_name).first.try(:code)
              value = rule.field_value
              all_pitches = (all_pitches & all_pitches.where("custom_fields.#{code}" => value))
            end
          end
        end
      end
      return all_pitches.flatten.uniq
  end
end
