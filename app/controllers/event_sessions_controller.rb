class EventSessionsController < ApplicationController
require 'csv'

  before_filter :load_dependencies

  def destroy
    @event_session = @program_event.event_sessions.find(params[:id])
    @event_session.destroy
    redirect_to :back
  end

  def export_event_session
    begin
    @event_session = @program_event.event_sessions.find(params[:id])
    @event_records = @event_session.event_records
    csv_string = EventSession.to_csv(@event_records)
    file_name = "#{@program_event.title}_#{@event_session.location}".gsub(" ", "_").gsub(",", "")
    send_data csv_string,
    :type => 'text/csv; charset=iso-8859-1; header=present',
    :disposition => "attachment; filename=#{file_name}.csv"
    rescue Exception => e
      flash[:notice] = "#{e.message}"
      redirect_to :back and return
    end
  end

  def print_event_session
    begin
      @event_session = @program_event.event_sessions.find(params[:id])
      file_name = EventSession.to_pdf(@event_session)
      File.open("#{Rails.root.to_s}/tmp/#{file_name}", 'r') do |f|
        send_data f.read, type: "pdf"
      end
    File.delete("#{Rails.root.to_s}/tmp/#{file_name}")
    rescue Exception => e
      flash[:notice] = "#{e.message}"
      redirect_to :back and return
    end
  end

  def message_all
    Resque.enqueue(App::Background::MessageAllParticipant,params[:event_session_id] , params[:title], params[:description])
    flash[:notice] = "Message Sent"
    redirect_to :back
  end

  def message_all
    Resque.enqueue(App::Background::MessageAllParticipant,params[:event_session_id] , params[:title], params[:description])
    flash[:notice] = "Process Successful"
    redirect_to :back
  end

  private

  def load_dependencies
    @program ||= Program.find(params[:program_id])
    @program_event ||= @program.program_events.find(params[:event_id])
  end

end
