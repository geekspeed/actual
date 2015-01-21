namespace :app do

  namespace :inactive_users do

    desc "Inactive user mail sender"
    task :user_reminder => :environment do
      puts "\n\n[START] Sending Mails to inactive users at #{Time.now}"
      Program.all.each do |program|
        if program.try(:mail_scheduling).blank?
          puts "\nFor Program #{program.title} / ID: #{program.id}"
          if !program.course_setting.blank? && program.try(:course_setting).try(:automated_inactive_email)
            CourseSetting.user_reminder_mail(program, program.course_setting)
          end
        end
      end
      puts "[END] Sending Mails to inactive users at #{Time.now}\n\n"
    end

  end

end

