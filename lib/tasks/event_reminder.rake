namespace :app do

  namespace :events do

    desc "Inactive user mail sender"
    task :reminder => :environment do
      puts "\n\n[START] Sending Mails for events reminder at #{Time.now}"
      EventRecord.each do |er|
        if er.event_session.date == Date.tomorrow and !er.rejected_at
          EventRecord.send_email(er.event_session, er.user)
        end
      end
      puts "[END] Sending Mails for events reminder at #{Time.now}\n\n"
    end

  end

end

