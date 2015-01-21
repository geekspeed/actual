class MailSetting
  include Mongoid::Document
  FREQUENCY = {"Once a day" => "day", "Once a week" => "week", 
    "Once a month" => "month", "Never"=> "never"}
  FREQUENCY_VALUES = FREQUENCY.values

  EVERYDAY = ["everyday", "weekdays_only"]
  WEEK = ["monday", "tuesday", "wednesday", "thursday", "friday", 
    "saturday", "sunday"]
  MONTH = (1..31).to_a
  DAILY = ["never", "everyday", "weekly"]

  belongs_to :program

  field :iterations,    :type => String, :default => FREQUENCY_VALUES.first
  field :iteration_day, :type => String, :default => "everyday"
  field :feedback,      :type => String, :default => FREQUENCY_VALUES.first
  field :feedback_day,  :type => String, :default => "everyday"
  field :problems,      :type => String, :default => FREQUENCY_VALUES.first
  field :problem_day,   :type => String, :default => "everyday"
  field :learnings,     :type => String, :default => FREQUENCY_VALUES.first
  field :learning_day,  :type => String, :default => "everyday"
  field :pitch_fields,  :type => String, :default => FREQUENCY_VALUES.first
  field :pitch_field_day,:type => String, :default => "everyday"
  field :feed_day,      :type => String, :default => "everyday"
  field :project_update,:type => String, :default => FREQUENCY_VALUES.first
  field :project_update_day,:type => String, :default => "everyday"
  field :activity_feeds,:type => String, :default => "everyday"
  field :admin_activity_feeds,:type => Boolean , :default => false
  field :immediate_post_program_feed, :type => Boolean , :default => false
  field :immediate_post_project_feed, :type => Boolean , :default => false

  validates :iterations, :feedback, :problems, :learnings, :pitch_fields, :project_update, presence: true, inclusion: FREQUENCY_VALUES

  def trigger_iterations(pitch)
    send("trigger_#{iterations}", "iterations", 
      "iteration_day", "pitch_iteration", pitch.user.id, pitch.id)
  end

  def trigger_feedback(pitch)
    send("trigger_#{feedback}", "feedback", 
      "feedback_day", "pitch_external_feedback", pitch.user.id, pitch.id)
  end

  def trigger_problems(pitch)
    send("trigger_#{problems}", "problems", 
      "problem_day", "pitch_problems", pitch.user.id, pitch.id)
  end

  def trigger_learnings(pitch)
    send("trigger_#{learnings}", "learnings", 
      "learning_day", "pitch_learnings", pitch.user.id, pitch.id)
  end

  def trigger_pitch_fields(pitch)
    if !!pitch.blank_field
      send("trigger_#{pitch_fields}", "pitch_fields", 
      "pitch_field_day", "pitch_fields", pitch.user.id, pitch.id)
    end
  end

  def trigger_project_update(pitch)
    send("trigger_#{project_update}", "project_update", 
      "project_update_day", "pitch_update", pitch.user.id, pitch.id)
  end
  

  def trigger_day(field, trigger_field, mail_method, *args)
    today = Date.today.strftime("%A").downcase
    if (send(trigger_field.to_sym) == "weekdays_only" && 
      !["saturday", "sunday"].include?(today)) || 
      send(trigger_field.to_sym) == "everyday"
      #background IT
      Resque.enqueue(App::Background::UserAdoption, mail_method, 
      *args)
    end
  end

  def trigger_week(field, trigger_field, mail_method, *args)
    today = Date.today.strftime("%A").downcase
    if send(trigger_field.to_sym) == today
      #background IT
      Resque.enqueue(App::Background::UserAdoption, mail_method, 
      *args)
    end
  end

  def trigger_month(field, trigger_field, mail_method, *args)
    day_of_month = Date.today.day
    if send(trigger_field.to_sym) == day_of_month
      #background IT
      Resque.enqueue(App::Background::UserAdoption, mail_method, 
      *args)
    end
  end

  def trigger_never(field, trigger_field, mail_method, *args)
    puts "triggering never"
  end

  def self.send_survey_mail
    date1= Time.now
    Survey.all.each do|survey|
      if survey.visibility.include? "email"
        date2= survey.recurring_period_update 
        if send_email?(date1,date2,survey.recurring_period)
          Resque.enqueue(App::Background::SurveyMail, survey.id)
        end
      end
    end
  end
  
  private
  
  def self.send_email?(date1,date2,recurring_period)
    same_day = date1.day == date2.day
    month_diff= (date1.month - date2.month).abs%recurring_period == 0
    same_day and month_diff
  end

end
