class WorkflowMilestone
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :due_date, type: Date
  belongs_to :workflow
end
