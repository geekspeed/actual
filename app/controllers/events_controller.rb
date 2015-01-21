class EventsController < ApplicationController
  
  skip_before_filter :authenticate_user!, :only => [:accept]
  
  before_filter :load_program

  def index
    @program_events = @program.program_events.all
    @program_event = @program.program_events.new
  end

  def edit
    @program_event = @program.program_events.find(params[:id])
  end

  def create
    if @program.update_attributes(params[:program])
      flash[:notice] = "Event created successfully!!"
    end
    redirect_to :back
  end

  def update
    @program_event = @program.program_events.find(params[:id])
    @program_event.update_attributes(params[:program_event])
    flash[:notice] = "Updated Successfully"
    redirect_to :back
  end

  def destroy
    @program_event = @program.program_events.find(params[:id])
    @program_event.destroy
    redirect_to :back
  end

  def accept
    if current_user and (need?(["mentor", "selector", "panellist", "participant"], @program) or need?(["company_admin"], current_organisation))
      @program_event = @program.program_events.find(params[:id])
      @event_session = @program_event.event_sessions.find(params[:for])
      task = Task.where(task_option2: params[:id]).first
      task.completed_tasks.create!(user: current_user, completed: true, date: Date.today) if task
      @event_session.event_records.find_or_initialize_by(event_session_id: @event_session.id , user_id: current_user.id).update_attributes(:program => @program)
      event_record = EventRecord.where(event_session_id: @event_session.id , user_id: current_user.id).first
      pitches = get_user_pitches(@program)
      create_tasks(pitches, event_record)
      unless @event_session.event_records.selected.count > @event_session.seat_no
        Resque.enqueue(App::Background::RegisteredEvent, event_record.user_id ,@event_session.id)
        flash[:notice] = "Thanks for registering!"
      else
        Resque.enqueue(App::Background::EventFull, current_user.id, @event_session.id)
        flash[:notice] = "This event has reached his capacity, you have been added to a waiting list."
      end
      redirect_to :back and return
    else
      redirect_to program_login_program_path(@program)
    end
  end

  def manage_participant
    @program_event = @program.program_events.find(params[:id])
    @event_session = @program_event.event_sessions.find(params[:event_session])
     respond_to do |format|
       format.html {render :partial => "manage_participant"}
       format.json { head :no_content }
    end
  end

  def reject_participant
    @program_event = @program.program_events.find(params[:program_event_id])
    @event_session = @program_event.event_sessions.find(params[:event_session_id])
    @event_record = @event_session.event_records.find(params[:event_record_id])
    @event_record.update_attributes(:rejected_at => Time.now)
    pitches = user_pitches(@program, @event_record.user_id)
    remove_tasks(pitches, @event_record)
    Resque.enqueue(App::Background::RejectParticipant,@event_record.id , params[:title], params[:description])
     respond_to do |format|
       format.html {render :nothing => "true"}
       format.json {render :json => {:status => "true", :event_record_id => @event_record.id, :event_session_id => @event_session.id }.to_json }
    end
  end

  def confirm_participant
    event_record = EventRecord.where(id: params[:record_id]).first
    confirmed_at = params[:confirmed] == "true" ? Date.today : nil
    event_record.update_attribute(:confirmed_at, confirmed_at)
    user = event_record.user
    if params[:confirmed] == "true" and event_record.program.try(:can_rate_events)
      Token.create_active_tokens(event_record.event_session, user.id)
      Resque.enqueue(App::Background::RateEventSession, event_record.event_session_id , user.id)
    end
    complete_task(user, event_record, @program, params[:confirmed])
    render :json => true
  end

  private

  def load_program
    @program ||= Program.find(params[:program_id])
  end
  
  def get_user_pitches(program)
    pitches = program.pitches.or(:user_id => current_user.id.to_s).or(:members => current_user.id.to_s).or(:mentors => current_user.id.to_s)
  end

  def user_pitches(program, user_id)
    user = User.find(user_id)
    pitches = program.pitches.or(:user_id => user.id.to_s).or(:members => user.id.to_s).or(:mentors => user.id.to_s)
  end
  
  def create_tasks(pitches, event_record)
    event_session = EventSession.find(event_record.event_session_id)
    event = ProgramEvent.find(event_session.program_event_id)
    pitches.each do |pitch|
      milestone = pitch.milestones.first
      milestone.tasks.create(:description => "Attend #{event.title} #{event_session.date.day} #{event_session.date.strftime("%B")}", :deadline => event_session.date,:user_id => current_user.id, :pitch_id => pitch.id, :event_record_id => event_record.id)
    end
  end

  def remove_tasks(pitches, event_record)
    pitches.each do |pitch|
      milestone = pitch.milestones.first
      milestone.tasks.where(:event_record_id => event_record.id).destroy
    end
  end
  
  def complete_task(user, event_record, program, confirmed_at)
    event_session = EventSession.find(event_record.event_session_id)
    event = ProgramEvent.find(event_session.program_event_id)
    pitches = program.pitches.or(:user_id => user.id.to_s).or(:members => user.id.to_s).or(:mentors => user.id.to_s)
    pitches.each do |pitch|
      milestone = pitch.milestones.first
      if milestone
        task = milestone.tasks.where(:user_id => user.id, :event_record_id => event_record.id).first
        if task
          confirmed_at == "true" ? task.update_attributes(:complete => true) : task.update_attributes(:complete => false)
        end
      end
    end
  end
end
