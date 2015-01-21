namespace :app do

  namespace :user_adoption do

    desc "User adoption mail sender"
    task :mails => :environment do
      puts "\n\n[START] Sending User adoption mails at #{Time.now}"
      MailSetting.send_survey_mail
      Program.all.each do |program|
        if program.try(:mail_scheduling).blank?
          puts "\nFor Program #{program.title} / ID: #{program.id}"
          @setting = MailSetting.find_or_create_by(program: program)
          program.pitches.each do |pitch|
            puts "\tFor Pitch #{pitch.title} / ID: #{pitch.id}"
            @setting.trigger_iterations(pitch)
            @setting.trigger_feedback(pitch)
            @setting.trigger_problems(pitch)
            @setting.trigger_learnings(pitch)
            
            @setting.trigger_pitch_fields(pitch)
            @setting.trigger_project_update(pitch)
          end
        end
      end
     end
      task :custom_mails => :environment do
        puts "\n\n[START] Sending User adoption mails at #{Time.now}"
        Program.all.each do |program|
          if program.try(:mail_scheduling).blank?
            puts "\nFor Program #{program.title} / ID: #{program.id}"
            @custom_reminders = program.custom_reminders
            if @custom_reminders.present?
              @custom_reminders.each do |custom_reminder|
                custom_reminder.trigger_mail
              end
            end 
          end
        end
        puts "[END] Sending User adoption mails at #{Time.now}\n\n"
    end
  end
end
#Weekday
# %A - The full weekday name (``Sunday'')
#Date.today.strftime("%A").downcase
# Day of month date.day