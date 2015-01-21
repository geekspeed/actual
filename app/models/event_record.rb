class EventRecord
  include Mongoid::Document
  include Mongoid::Timestamps

  field :confirmed_at,  :type => Date
  field :rejected_at,  :type => Date

  belongs_to :event_session
  belongs_to :user
  belongs_to :program
  
  default_scope ascending('created_at')
  scope :for_program, lambda{|program| where(:program_id => program)}
  scope :for_user, lambda{|user| where(:user_id => user)}
  scope :selected, where(:rejected_at => nil)
  scope :rejected, where(:rejected_at.ne => nil)
  validates_uniqueness_of :event_session_id, :scope => :user_id
  
  def self.send_email(event_session, user)
    Resque.enqueue(App::Background::EventsReminder, event_session.id ,user.id)
  end

  def check_for_achievement
    if self.confirmed_at.present?
      expired = false
      program_event_id = event_session.program_event_id
      ary = []
      ary << program.badge_rules.where(criteria: "events", sub_criteria: "Attend", event_session_id: event_session_id, program_event_id: program_event_id).first
      ary << program.badge_rules.where(criteria: "events", sub_criteria: "Attend", event_session_id: event_session_id, program_event_id: "").first
      ary << program.badge_rules.where(criteria: "events", sub_criteria: "Attend", event_session_id: "", program_event_id: program_event_id).first
      ary.each do |badge_rule|
        if badge_rule.present?
          case badge_rule.expiry
           when "fixed_date"
             Date.today <= badge_rule.expiry_date ? (expired = false): (expired = true)
           when "relative_date"
             ((Date.today - badge_rule.created_at.to_date) <= badge_rule.expiry_day) ? (expired = false): (expired = true)
          end
          if !expired
            user_badge = UserBadge.where(app_badge_id: badge_rule.app_badge.id, user_id: user_id).first
            user_badge.update_attributes(:iteration => user_badge.iteration + 1)
          end
        end
      end
    end
  end

  def check_for_signup_badge
    expired = false
    badge_rule = program.badge_rules.where(criteria: "events", sub_criteria: "Signup").first
    if badge_rule.present?
      case badge_rule.expiry
       when "fixed_date"
         Date.today <= badge_rule.expiry_date ? (expired = false): (expired = true)
       when "relative_date"
         ((Date.today - badge_rule.created_at.to_date) <= badge_rule.expiry_day) ? (expired = false): (expired = true)
      end
      if !expired
        user_badge = UserBadge.where(app_badge_id: badge_rule.app_badge.id, user_id: user_id).first
        user_badge.update_attributes(:iteration => user_badge.iteration + 1)
      end
    end
  end
end
