every :day, :at => '01:30pm', :roles => [:app] do
  rake "app:user_adoption:mails"
end

every 5.minutes, :roles => [:app] do
  rake "app:eventbrite_event:attendees"
end

every :day, :at => '03:30pm', :roles => [:app] do
  rake "app:activity_feed:daily_mails"
end

every :week, :at => '05:30pm', :roles => [:app] do
  rake "app:activity_feed:weekly_mails"
end

every :day, :at => '07:30pm', :roles => [:app] do
  rake "app:project_feed:daily_mails"
end

every :week, :at => '09:30pm', :roles => [:app] do
  rake "app:project_feed:weekly_mails"
end

every :day, :at => '11:30pm', :roles => [:app] do
  rake "app:inactive_users:user_reminder"
end

every :day, :at => '01:00am', :roles => [:app] do
  rake "app:events:reminder"
end

every :day, :at => '02:30pm', :roles => [:app] do
  rake "app:user_adoption:custom_mails"
end

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
