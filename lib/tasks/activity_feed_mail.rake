namespace :app do

  namespace :activity_feed do

    desc "Activity Feed mail sender"
    task :daily_mails => :environment do
      puts "\n\n[START] Sending User activity feed mails at #{Time.now}"
      Program.all.each do |program|
        if program.try(:mail_scheduling).blank?
          puts "\nFor Program #{program.title} / ID: #{program.id}"
          mail_setting = MailSetting.where(:program_id => program.id).first
          if mail_setting.try(:activity_feeds) == "everyday"
            ActivityFeed.activity_feed_mail(program,"everyday")
          end
        end
      end
      puts "[END] Sending User activity feed mails at #{Time.now}\n\n"
    end
    task :weekly_mails => :environment do
      puts "\n\n[START] Sending User activity feed mails at #{Time.now}"
      Program.all.each do |program|
        if program.try(:mail_scheduling).blank?
          puts "\nFor Program #{program.title} / ID: #{program.id}"
          mail_setting = MailSetting.where(:program_id => program.id).first
          if mail_setting.try(:activity_feeds) == "weekly" || mail_setting.blank?
            ActivityFeed.activity_feed_mail(program,"weekly")
          end
        end
      end
      puts "[END] Sending User activity feed mails at #{Time.now}\n\n"
    end
  end

end

#Weekday
# %A - The full weekday name (``Sunday'')
#Date.today.strftime("%A").downcase
# Day of month date.day