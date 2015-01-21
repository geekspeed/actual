class CustomEvent
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program
  belongs_to :pitch
  belongs_to :created_by, :class_name => "User"

  field :title, :type => String
  field :description, :type => String
  field :session_date, :type => Date
  field :duration_hours, :type => Integer, :default => 0 
  field :duration_mins, :type => Integer, :default => 0
  field :attendee, :type => Array, :default => []
  field :program_event_id, :type => String
  field :event_session_id, :type => String
  
  def check_for_achievement
    if self.event_session_id
      expired = false
      badge_rule = program.badge_rules.where(criteria: "events", sub_criteria: "Attend", event_session_id: self.event_session_id).first
      if badge_rule.present?
        case badge_rule.expiry
         when "fixed_date"
           Date.today <= badge_rule.expiry_date ? (expired = false): (expired = true)
         when "relative_date"
           ((Date.today - badge_rule.created_at.to_date) <= badge_rule.expiry_day) ? (expired = false): (expired = true)
        end
        if !expired
          attendee.each do |user_id|
            user_badge = UserBadge.where(app_badge_id: badge_rule.app_badge.id, user_id: user_id).first
            if user_badge
              user_badge.update_attributes(:iteration => user_badge.iteration + 1)
            end
          end
        end
      end
    end
  end
  
end