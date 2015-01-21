class MessageMailer < ActionMailer::Base
  include Devise::Mailers::Helpers
  # default from: Devise.mailer_sender

  def message_all(users, subject, body, organisation)
  	@users = users
  	@body = body
  	@organisation = organisation
    users.each do |user|
      mail(to: user, subject: subject, from: "#{@organisation.company_name} <info@apptual.com>").deliver
    end
  end
end
