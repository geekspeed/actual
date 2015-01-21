class UserContactRequestsController < ApplicationController

  def create
    begin
      contact_request = current_user.contact_requests.create!(params[:user_contact_request])
      Resque.enqueue(App::Background::SendContactRequest, contact_request.id)
      flash[:notice] = "Request successfully sent."
      redirect_to :back
    rescue Exception => e
      flash[:notice] = e.message
    end
  end

end