class PitchCustomFeedbacksController < ApplicationController
  before_filter :load_dependency

  def create
    @feedback = @pitch.custom_feedbacks.build(params[:pitch_custom_feedback])
    @feedback.user = current_user
    @feedback.program = @program
    if @feedback.save
      flash[:notice] = "Feedback successfully sent"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end
  
  def destroy
    @feedback = PitchCustomFeedback.find(params[:id])
    if @feedback.destroy
      flash[:notice] = "Feedback deleted successfully"
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