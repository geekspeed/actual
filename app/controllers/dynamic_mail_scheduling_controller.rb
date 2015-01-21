class DynamicMailSchedulingController < ApplicationController
  before_filter :load_program

  def index  
    if context_program.mail_scheduling.blank?
      @mail_scheduling = context_program.build_mail_scheduling
    else
      @mail_scheduling = context_program.mail_scheduling
    end
  end

  def create
    if context_program.mail_scheduling.blank?
      mail_scheduling_saved
      mail_scheduling_saved.save
      flash[:notice] = "Mail Scheduling successfully saved"     
    else
      mail_scheduling_updated
      flash[:notice] = "Mail Scheduling successfully updated"
    end  
    scheduling_mails
    redirect_to :back
  end 

private

  def mail_scheduling_saved
    context_program.build_mail_scheduling(params[:mail_scheduling])
  end

  def mail_scheduling_updated
    context_program.mail_scheduling.update_attributes(params[:mail_scheduling])
  end
  
  def load_program
    @program ||= Program.find(params[:program_id])
  end

  def scheduling_mails
    mail_scheduling = @program.mail_scheduling
    daily_mails(mail_scheduling)
    weekly_mails(mail_scheduling)
  end
  
  def time_calculation(time)
    time.split(":")
  end

  def scheduling_user_adoption_mail(schedule_time)
    cron = "#{time_calculation(schedule_time)[1]} #{time_calculation(schedule_time)[0]} * * *"
    scheduling_mails_job(cron, "user_adoption_mail_daily_#{@program.id}", 'App::Background::ScheduledUserAdoptionMail')
  end

  def scheduling_activity_feed_mail_daily(schedule_time)
    cron = "#{time_calculation(schedule_time)[1]} #{time_calculation(schedule_time)[0]} * * *"
    scheduling_mails_job(cron, "activity_feed_mail_daily_#{@program.id}", 'App::Background::ScheduledActivityFeedMail')
  end

  def scheduling_activity_feed_mail_weekly(schedule_time)
    cron = "#{time_calculation(schedule_time)[1]} #{time_calculation(schedule_time)[0]} 1,8,15,22 * *"
    scheduling_mails_job(cron, "activity_feed_mail_weekly_#{@program.id}", 'App::Background::ScheduledActivityFeedMailWeekly')
  end  

  def scheduling_project_feed_mail_daily(schedule_time)
    cron = "#{time_calculation(schedule_time)[1]} #{time_calculation(schedule_time)[0]} * * *"
    scheduling_mails_job(cron, "project_feed_mail_daily_#{@program.id}", 'App::Background::ScheduledProjectFeedMail')
  end

  def scheduling_project_feed_mail_weekly(schedule_time)
    cron = "#{time_calculation(schedule_time)[1]} #{time_calculation(schedule_time)[0]} 1,8,15,22 * *"
    scheduling_mails_job(cron, "project_feed_mail_weekly_#{@program.id}", 'App::Background::ScheduledProjectFeedMailWeekly')
  end

  def scheduling_inactive_users_mail_daily(schedule_time)
    cron = "#{time_calculation(schedule_time)[1]} #{time_calculation(schedule_time)[0]} * * *"
    scheduling_mails_job(cron, "inactive_users_mail_daily_#{@program.id}", 'App::Background::ScheduledInactiveUsersMail')
  end

  def daily_mails(mail_scheduling)
    scheduling_user_adoption_mail(mail_scheduling.try(:user_adoption))
    scheduling_activity_feed_mail_daily(mail_scheduling.try(:activity_feed))
    scheduling_project_feed_mail_daily(mail_scheduling.try(:project_feed))
    scheduling_inactive_users_mail_daily(mail_scheduling.try(:course_inactive_user))
  end

  def weekly_mails(mail_scheduling)
    scheduling_activity_feed_mail_weekly(mail_scheduling.try(:activity_feed))
    scheduling_project_feed_mail_weekly(mail_scheduling.try(:project_feed))
  end

  def scheduling_mails_job(cron, name, class_name)
    name = name
    config = {}
    config[:class] = class_name
    config[:args] = @program.id
    config[:cron] = cron
    config[:persist] = true
    Resque.set_schedule(name, config)
  end

end
