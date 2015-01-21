class FeedbacksController < ApplicationController
  before_filter :load_dependency

  def index
    @feedbacks = @pitch.feedbacks.desc(:create_at)
    @custom_feedbacks = @pitch.custom_feedbacks
    @due_diligences = @pitch.pitch_due_diligence_matrices
    render layout: "application_new_design"
  end

  def create
    
    @feedback = @pitch.feedbacks.build(params[:pitch_feedback])
    @feedback.user = current_user
    if @feedback.save
      PitchFeedback.feedback_email(@feedback.user,@pitch,@feedback.id)
      d(@feedback.inspect)
      @program.activity_feeds.create(:type=>"pitch_feedback", :user_id => current_user.id, :pitch_id=> @pitch.id, :feedback_id => @feedback.id)
      flash[:notice] = "Feedback successfully sent"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  def destroy
    @feedback = PitchFeedback.find(params[:id])
    if @feedback.destroy
      flash[:notice] = "Feedback deleted successfully"
      activity_feed = ActivityFeed.where(:feedback_id => @feedback.id).first
      if activity_feed
        community_feed = CommunityFeed.where(id: activity_feed.community_feed_id).first
        if community_feed
          community_feed.destroy
        end
        activity_feed.destroy
      end
    else
      flash[:notice] = "Problem deleting feedback"
    end
    redirect_to :back
  end

  private

  def load_dependency
    @program = Program.find(params[:program_id])
    @pitch = @program.pitches.find(params[:pitch_id])
  end
end
