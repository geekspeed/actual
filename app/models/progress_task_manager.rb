class ProgressTaskManager
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program

  field :hustle_required,                 :type => Float, :default => 0
  field :hustle_required_deadline,        :type => Date

  field :iteration_required,              :type => Float, :default => 0
  field :iteration_required_deadline,     :type => Date

  field :feedback_required,               :type => Float, :default => 0
  field :feedback_required_deadline,      :type => Date

  field :grace_period_required,           :type => Float, :default => 0
  field :grace_period_required_deadline,  :type => Date

  field :progress_update_required,         :type => Float, :default => 0
  field :progress_update_required_deadline,:type => Date

  validates :hustle_required, :hustle_required_deadline, 
    :iteration_required, :iteration_required_deadline,
    :feedback_required, :feedback_required_deadline,
    :grace_period_required, :grace_period_required_deadline,
    :progress_update_required, :progress_update_required_deadline, :presence => true
end
