class EventRating
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :identity, polymorphic: true
  
  field :rating, :type => Integer
  field :comment, :type => String
  
  validates_uniqueness_of :identity_id, :scope => :user_id
  
  def check_for_achievement
    expired = false
    badge_rule = program.badge_rules.where(criteria: "events", sub_criteria: "Provide Feedback").first
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