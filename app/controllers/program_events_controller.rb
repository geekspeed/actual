class ProgramEventsController < ApplicationController
  
  def index
    @event_records = EventRecord.for_program(context_program).for_user(current_user)
    render :layout => "application_new_design"
  end
  
end
