class UserBadge
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :check_assignment

  belongs_to :app_badge
  belongs_to :user

  field :active,       type: Boolean, default: false
  field :iteration,    type: Integer, default: 0
  field :revoked,      type: Boolean, default: false
  
  scope :active_badges, where(active: true)

  def check_assignment
    badge = self.app_badge
    unless active
      if ((badge.badge_rule.event_session_id.present? or badge.badge_rule.program_event_id.present?) and (iteration >= 1)) or (badge.badge_rule.instances <= iteration)
        self.active = true
        self.app_badge.program.activity_feeds.create(:type=>"badge_awarded", :user_id => self.user_id, :user_badge_id => self.id)
      end
    else
      if badge.badge_rule.criteria == "manual"
        self.app_badge.program.activity_feeds.create(:type=>"badge_awarded", :user_id => self.user_id, :user_badge_id => self.id)
      end
    end
  end

end