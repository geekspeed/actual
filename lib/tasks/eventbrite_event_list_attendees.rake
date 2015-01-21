namespace :app do

  namespace :eventbrite_event do

    desc "Check for evenbrite events attendees"
    task :attendees => :environment do
      ProgramPlan.where(:eventbrite_id.ne => nil, :date.gt => Time.now).each do |plan|
        plan.program_summary.eventbrite_user_keys.each do |account|
         begin
            eb_auth_tokens = { app_key: EventBrite_KEY,access_token: account["token"]}
           @eb_client = EventbriteClient.new(eb_auth_tokens)
            event_attendees = @eb_client.event_list_attendees({:id => plan.eventbrite_id})
            event_attendees["attendees"].each do |event_attendee|
              attendee = event_attendee["attendee"]
              user = User.where(email: attendee["email"]).first
              if user
                plan.add_to_attendees! user.id.to_s unless plan.signed_up?(user.id.to_s)
              end
           end
         rescue Exception => e
           next
         end
       end
      end
    end
  end

end

#Weekday
# %A - The full weekday name (``Sunday'')
#Date.today.strftime("%A").downcase
# Day of month date.day