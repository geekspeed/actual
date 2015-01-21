class PitchDocument
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_protected :approved_by_mentors

  field :description,     :type => String, :default => ""
  mount_uploader :attachment, AttachmentUploader

  belongs_to :pitch
  belongs_to :user

  #list of mentors ids
  field :approved_by_mentors,  :type => Array, :default => []

  validates :description, :presence => true

  def approve!(mentor)
    mentor_id = mentor.respond_to?(:id) ? mentor.id : mentor
    mentors = approved_by_mentors + [mentor_id]
    update_attribute(:approved_by_mentors, mentors)
  end

  def approved_by_mentors
    User.find(read_attribute(:approved_by_mentors))
  end

  def check_for_achievement
    if self.attachment.content_type == "text/plain"
      badge_rule = pitch.program.badge_rules.where(criteria: "project", sub_criteria: "Upload txt document").first
    elsif ["image/png", "image/jpg", "image/jpeg", "image/gif"].include?(self.attachment.content_type)
      badge_rule = pitch.program.badge_rules.where(criteria: "project", sub_criteria: "Upload document image").first
    end

    expired = false
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
