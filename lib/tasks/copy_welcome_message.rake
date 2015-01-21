namespace :copy do
  desc "[copy] copy the welcome message to welcome messages for different roles"
  task :copy_welcome_message => :environment do
    ProgramSummary.all.each do |summary|
      unless summary.try(:welcome_message).blank?
        if summary.try(:summary_welcome_message)
          summary.summary_welcome_message.update_attributes(:message_for_applicant => summary.try(:welcome_message) , :message_for_mentor => summary.try(:welcome_message) ,:message_for_selector =>summary.try(:welcome_message) ,:message_for_panellist => summary.try(:welcome_message) )
        else
          summary.create_summary_welcome_message(:message_for_applicant => summary.try(:welcome_message) , :message_for_mentor => summary.try(:welcome_message) ,:message_for_selector =>summary.try(:welcome_message) ,:message_for_panellist => summary.try(:welcome_message) )
        end
      end
    end
  end
end