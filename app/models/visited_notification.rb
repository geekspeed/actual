class VisitedNotification
  include Mongoid::Document  
  include Mongoid::Timestamps

  belongs_to :program
  belongs_to :user
  field :type,  :type => String,  :default => ""
  default_scope desc(:created_at)
  scope :for_program, lambda{|program| where(:program_id => program)}
  scope :for_program_and_notification_type, lambda{|program, type| where(:program_id => program, :type => type)}
end
