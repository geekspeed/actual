class VisitedNotificationsController < ApplicationController  

before_filter :load_program

  def create
  	visited_notification = current_user.visited_notifications.create(:program_id => @program.id, :type => params[:type])
  	redirect_to params[:notification_url]
  end

  private

  def load_program
    @program ||= Program.find(params[:program_id])
  end

end
