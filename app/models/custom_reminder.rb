class CustomReminder
  include Mongoid::Document
  include Mongoid::Timestamps

  FREQUENCY = {"Once a day" => "day", "Once a week" => "week", 
    "Once a month" => "month", "Never"=> "never"}
  FREQUENCY_VALUES = FREQUENCY.values

  EVERYDAY = ["everyday", "weekdays_only"]
  WEEK = ["monday", "tuesday", "wednesday", "thursday", "friday", 
    "saturday", "sunday"]
  MONTH = (1..31).to_a
  DAILY = ["everyday", "weekly"]

  field :subject,  :type => String,  :default => ""
  field :message,  :type => String,  :default => ""
  field :to_target,  :type => String
  field :frequency,    :type => String, :default => FREQUENCY_VALUES.first
  field :reminder_day, :type => String, :default => "everyday"

  belongs_to :program

  validates :frequency, presence: true, inclusion: FREQUENCY_VALUES
  
  def trigger_mail
    users = Targetting.find_users(to_target, program_id)
    users_emails = User.in(:id => users).map(:email)
    send("trigger_#{frequency}", "reminder_day", users_emails, subject, message, program.organisation)
  end
  
  def trigger_day(trigger_field, emails, subject, message, organisation)
    today = Date.today.strftime("%A").downcase
    if (send(trigger_field.to_sym) == "weekdays_only" && 
      !["saturday", "sunday"].include?(today)) || 
      send(trigger_field.to_sym) == "everyday"
      #background IT
      Resque.enqueue(App::Background::MessageMailer, emails, subject, message, organisation.id)
    end
  end

  def trigger_week(trigger_field, emails, subject, message, organisation)
    today = Date.today.strftime("%A").downcase
    if send(trigger_field.to_sym) == today
      #background IT
      Resque.enqueue(App::Background::MessageMailer, emails, subject, message, organisation.id)
    end
  end

  def trigger_month(trigger_field, emails, subject, message, organisation)
    day_of_month = Date.today.day
    if send(trigger_field.to_sym) == day_of_month
      #background IT
      Resque.enqueue(App::Background::MessageMailer, emails, subject, message, organisation.id)
    end
  end

  def trigger_never(trigger_field, emails, subject, message, organisation)
    puts "triggering never"
  end
end
