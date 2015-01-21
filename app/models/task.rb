class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description,     :type => String
  field :deadline,        :type => Date
  field :complete,        :type => Boolean,   :default => false
  field :task_type,       :type => String,    :default => "user_task"
  field :task_label,      :type => String
  field :task_option1,    :type => String
  field :task_option2,    :type => String
  field :task_option3,    :type => String
  field :assigned_to,     :type => Array,     :default => []
  field :milestone_flag,  :type => Boolean,   :default => false
  field :event_record_id, :type => String
  field :session ,        :type => Boolean,   :default => false


  belongs_to :milestone
  belongs_to :user
  belongs_to :pitch
  has_many :completed_tasks

  validates :milestone_id, :description, :presence => true

  def complete!
    update_attribute(:complete, !complete)
  end

  def self.filter_period(period)
    case period
      when "Today"
        Date.today
      when "Yesterday"
        Date.today - 1.day
      when "Tomorrow"
        Date.today + 1.day
      when "Last Week"
        (Date.today.beginning_of_week - 1.week)..(Date.today.end_of_week - 1.week)
      when "This Week"
        Date.today.beginning_of_week..Date.today.end_of_week
      when "This Month"
        Date.today.beginning_of_month..Date.today.end_of_month
    end
  end

  def create_description
    case task_option1
    when "workflow"
      workflow = Workflow.where(id: task_option2).first
      "Complete phase #{workflow.try(:phase_name)}"
    when "project"
      case task_option2
      when "iterate_field"
        "Iterate on your project in #{task_option3}"
      when "iterate"
        "Iterate on your project"
      when "ask_for_feedback"
        "Ask for feedback"
      end
    when "event"
      program_event = ProgramEvent.where(id: task_option2).first.try(:title)
      "Register for #{program_event}"
    end
  end

end
