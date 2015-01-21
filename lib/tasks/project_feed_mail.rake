namespace :app do

  namespace :project_feed do

    desc "Activity Feed mail sender"
    task :daily_mails => :environment do
      puts "\n\n[START] Sending User project feed mails at #{Time.now}"
      Rails.logger.warn "------in weekly activity feed------"
      Pitch.all.each do |pitch|
        if pitch.try(:program).try(:mail_scheduling).blank?
          puts "\nFor Program #{pitch.try(:title)} / ID: #{pitch.id}"
          mail_setting = MailSetting.where(:program_id => pitch.program.id).first
          if mail_setting.try(:feed_day) == "everyday"
            Rails.logger.warn "------in daily activity feed for #{pitch.try(:inspect)}----"
            ActivityFeed.project_feed_mail(pitch,"everyday")
          end
        end
      end
      puts "[END] Sending User activity feed mails at #{Time.now}\n\n"
    end
    task :weekly_mails => :environment do
      puts "\n\n[START] Sending User project feed mails at #{Time.now}"
      Rails.logger.warn "------in weekly activity feed------"
      Pitch.all.each do |pitch|
        if pitch.try(:program).try(:mail_scheduling).blank?
          puts "\nFor Program #{pitch.try(:title)} / ID: #{pitch.id}"
          mail_setting = MailSetting.where(:program_id => pitch.program.id).first
          if mail_setting.try(:feed_day) == "weekly" || mail_setting.blank?
            Rails.logger.warn "------in weekly activity feed for #{pitch.try(:inspect)}------"
            ActivityFeed.project_feed_mail(pitch,"weekly")
          end
        end
      end
      puts "[END] Sending User activity feed mails at #{Time.now}\n\n"
    end
  end

end