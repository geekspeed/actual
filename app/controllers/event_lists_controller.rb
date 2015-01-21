class EventListsController < ApplicationController
  
  def index
    @event_records = EventRecord.for_program(context_program)
    render :layout => "application_new_design"
  end
  
end
