class CustomEventsController < ApplicationController
  before_filter :load_program

  def create
    unless params[:custom_event][:title]
      params[:custom_event][:title] = "#{Semantic.translate(@program, "role_type:mentor", "singular")} session #{params[:custom_event][:session_date]}"
    end
    @custom_event = @program.custom_events.build(params[:custom_event])
    if @custom_event.save
      @program.activity_feeds.create(:type=>"log_mentor_session", :user_id => current_user.id, :pitch_id=> @custom_event.pitch.id, :custom_event_id => @custom_event.id)
      @custom_event.pitch.tasks.create(:milestone_id => @custom_event.pitch.milestones.first.id, :description => @custom_event.title, :user_id => @custom_event.created_by_id, :complete => true, :session => true)
      flash[:notice] = "Custom event saved successfully"
    else
      flash[:notice] = "Error creating custom event"
    end
    redirect_to :back
  end
  
  def log_admin_session
    @custom_event = @program.custom_events.build(params[:custom_event])
    if @custom_event.save
      if @custom_event.event_session_id.present?
        event_session = EventSession.where(id: @custom_event.event_session_id).first
        event_records = event_session.event_records.in(user_id: @custom_event.attendee)
        event_records.each do |er|
          confirmed_at = Date.today
          er.update_attribute(:confirmed_at, confirmed_at)
          user = er.user
          complete_task(user, er, @program)
        end
      else
        @program.activity_feeds.create(:type=>"log_admin_session", :user_id => current_user.id, :pitch_id=> @custom_event.pitch.id, :custom_event_id => @custom_event.id)
        @custom_event.pitch.tasks.create(:milestone_id => @custom_event.pitch.milestones.first.id, :description => @custom_event.title, :user_id => @custom_event.created_by_id, :complete => true, :session => true)
      end
      flash[:notice] = "Custom event saved successfully"
    else
      flash[:notice] = "Error creating custom event"
    end
    redirect_to :back
  end

  def get_event_sessions
    event_sessions = ProgramEvent.find(params[:event_id]).event_sessions.map{|pe| [pe.location, pe.id]}
    render :json => {event_sessions: event_sessions}
  end

  def get_event_sessions_for_badge
    event_sessions = ProgramEvent.find(params[:event_id]).event_sessions.map{|pe| [pe.description.first(20), pe.id]}
    render :json => {event_sessions: event_sessions}
  end

  def get_event_record_users
    event_session = EventSession.find(params[:event_session_id])
    event_records = event_session.event_records.where(rejected_at: nil).flatten.map{|er| [er.user.full_name, er.user.id]}
    time_from = time = ("#{event_session.date}  #{event_session.time_from}").to_time
    time_to = time = ("#{event_session.date}  #{event_session.time_to}").to_time
    time_of_session = time_to - time_from
    render :json => {event_records: event_records, date: event_session.date, hours: (Time.mktime(0)+time_of_session).hour, mins:(Time.mktime(0)+time_of_session).min}
  end

  private

  def load_program
    @program = Program.find(params[:program_id])
  end

  def complete_task(user, event_record, program)
    event_session = EventSession.find(event_record.event_session_id)
    event = ProgramEvent.find(event_session.program_event_id)
    pitches = program.pitches.or(:user_id => user.id.to_s).or(:members => user.id.to_s).or(:mentors => user.id.to_s)
    pitches.each do |pitch|
      milestone = pitch.milestones.first
      task = milestone.tasks.where(:user_id => user.id, :event_record_id => event_record.id).first
      if task
        task.update_attributes(:complete => true)
      end
    end
  end
end