class PitchFeedback
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :pitch

  field :content,   :type => String, :default => ""
  field :phase,     :type => String, :default => "application"
  field :private,   :type => Boolean, :default => false

  validates :content, :presence => true

  def self.feedback_email(feedback_user,pitch,feedback_id)
    @feedback_recievers = []
    @feedback_recievers << pitch.user
    @feedback_recievers << User.find(pitch.members)
    @subject = "FeedbackMail"
    @feedback_recievers.flatten.each do |feedback_reciever|
      Resque.enqueue(App::Background::FeedBackMail,feedback_user.id, feedback_reciever.id, pitch.program.id, pitch.program.class.to_s, pitch.id,feedback_id)
    end
  end

  def check_for_achievement
    expired = false
    badge_rule = pitch.program.badge_rules.where(criteria: "project", sub_criteria: "Feedback").first
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
