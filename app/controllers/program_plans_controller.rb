class ProgramPlansController < ApplicationController

  def destroy
    @program_plan = ProgramPlan.find params[:program_plan_id]
    if @program_plan.destroy
      flash[:notice] = "Programme Plan Destroyed"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end
  
  def attending
    @program_plan = ProgramPlan.find params[:program_plan_id]
    @program_plan.add_to_attendees! current_user.id.to_s
    redirect_to :back
  end
  
  def not_attending
    @program_plan = ProgramPlan.find params[:program_plan_id]
    @program_plan.add_to_not_attending! current_user.id.to_s
    redirect_to :back
  end
  
  def attendees
    @program_plan = ProgramPlan.find params[:program_plan_id]
    @attending_users = User.in(id: @program_plan.attendees)
    @not_attending_users = User.in(id: @program_plan.not_attending)
    render :partial => '/program_summaries/event_attendees'
  end
  
end