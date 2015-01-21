namespace :fix do
  desc "Updating event brite date issue to show start date for events"
  task :update_date => :environment do
    ProgramPlan.where(:eventbrite_id.ne => nil).each do |plan|
      begin
        program_summary = plan.try(:program_summary)
        eb_auth_tokens = { app_key: EventBrite_KEY,access_token: plan.user_access_token}
        @eb_client = EventbriteClient.new(eb_auth_tokens)
        event = @eb_client.event_get({:id => plan.eventbrite_id})["event"]
        old_plan = program_summary.program_plans.where(eventbrite_id: event["id"]).first
        old_plan.update_attributes(date_from: event["start_date"])
      rescue Exception => e
        next
      end
    end
  end
end