class UserAdoptionMailer < ActionMailer::Base
  include Devise::Mailers::Helpers
  # default from: Devise.mailer_sender

  def pitch_iteration(user, pitch)
    @user = User.find(user)
    @pitch = Pitch.find(pitch)
    @program = @pitch.program
    @organisation = @program.organisation
    @domain_host = DomainMapping.domain(@program)
    @subject = "#{@pitch.try(:title)}-Iteration"
    mail(to: @user.email, subject: @subject, from: "#{@program.title} <info@apptual.com>")
  end

  def pitch_external_feedback(user, pitch)
    @user = User.find(user)
    @pitch = Pitch.find(pitch)
    @program = @pitch.program
    @organisation = @program.organisation
    @subject = "#{@pitch.try(:title)}-Feedback"
    @domain_host = DomainMapping.domain(@program)
    mail(to: @user.email, subject: @subject, from: "#{@program.title} <info@apptual.com>")
  end

  def pitch_problems(user, pitch)
    @user = User.find(user)
    @pitch = Pitch.find(pitch)
    @program = @pitch.program
    @organisation = @program.organisation
    @subject = "#{@pitch.try(:title)}-Problems to solve"
    @domain_host = DomainMapping.domain(@program)
    mail(to: @user.email, subject: @subject, from: "#{@program.title} <info@apptual.com>")
  end

  def pitch_learnings(user, pitch)
    @user = User.find(user)
    @pitch = Pitch.find(pitch)
    @program = @pitch.program
    @organisation = @program.organisation
    @subject = "#{@pitch.try(:title)}-New Learning"
    @domain_host = DomainMapping.domain(@program)
    mail(to: @user.email, subject: @subject, from: "#{@program.title} <info@apptual.com>")
  end

  def pitch_update(user, pitch)
    @user = User.find(user)
    @pitch = Pitch.find(pitch)
    @program = @pitch.program
    @organisation = @program.organisation
    @subject = "#{@pitch.try(:title)}-Project Update"
    @domain_host = DomainMapping.domain(@program)
    mail(to: @user.email, subject: @subject, from: "#{@program.title} <info@apptual.com>")
  end

  def pitch_fields(user, pitch)
    @user = User.find(user)
    @pitch = Pitch.find(pitch)
    @program = @pitch.program
    @organisation = @program.organisation
    @subject = "#{@pitch.try(:title)}-Incomplete fields"
    @domain_host = DomainMapping.domain(@program)
    mail(to: @user.email, subject: @subject, from: "#{@program.title} <info@apptual.com>")
  end

end