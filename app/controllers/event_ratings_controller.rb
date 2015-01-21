class EventRatingsController < ApplicationController

  skip_before_filter :authenticate_user!

  def update
    @event_rating = EventRating.find(params[:event_rating_id])
    if @event_rating.update_attributes(params[:event_rating])
      flash[:notice] = "Rating updated successfully"
    else
      flash[:notice] = "Error updating comment"
    end
    redirect_to root_url
  end

end