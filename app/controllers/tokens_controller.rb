class TokensController < ApplicationController

  skip_before_filter :authenticate_user!

  def show
    @token = Token.find_by_digest(params[:id])
    unless params[:status]
      if @token and !@token.expired?
        @event = @token.identity
        @event.expire_all_tokens
        @event.rate_event(@token)
        @event.update_attributes(:feedback_status => "reviewed")
        flash[:notice] = "Rating Submitted."
      elsif @token and @token.expired? 
        flash.clear
        @status = "expired"
        flash.now[:alert] = "Sorry, your review has already been submitted."
      else
        flash.clear
        @status = "not_found"
        flash.now[:alert] = "Token not found!"
      end
    else
      @status = "submitted"
    end
  end

  def user_feedback
    @token = Token.where(:digest => params[:id]).first
      if @token and !@token.expired?
        begin
          @event_rating = @token.event_session.event_ratings.create!(:user_id => @token.user.id, :rating => @token.star)
          program=@event_rating.identity.program_event.program
          program.activity_feeds.create(:type=>"event_rating", :user_id => @event_rating.user_id, :event_rating_id => @event_rating.id)
          flash[:notice] = "Ratings successfully submited"
          @status = "ok"
        rescue Exception => e
          @status = "same_event"
          flash[:notice] = "You already submitted your rating."
        end
        Token.expire_all_tokens(@token.event_session, @token.user.id)
      elsif @token and @token.expired?
        @status = "expired"
        flash[:notice] = "Sorry, your review has already been submitted."
      else
        @status = "not found"
        flash[:notice] = "Token not found!"
      end
  end

end