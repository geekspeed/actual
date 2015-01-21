class MailScheduling
  include Mongoid::Document
  include Mongoid::Timestamps
  field :user_adoption, type: String
  field :activity_feed, type: String
  field :project_feed, type: String
  field :course_inactive_user, type: String
  belongs_to :program
end
