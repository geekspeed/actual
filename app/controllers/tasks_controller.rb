class TasksController < ApplicationController

  before_filter :load_dependency
  before_filter :check_task, :only => :create

  def create
    @task = Task.new(params[:task])
    @task.user = current_user
    @task.pitch = @pitch
     if @task[:task_type] == "system_task"
       @task[:description] = @task.create_description
       @task[:assigned_to] = @pitch.team
     end
    if @task.save
      @program.activity_feeds.create(:type=>"pitch_task", :user_id => current_user.id, :pitch_id=> params[:pitch_id], :task_id => @task.id)
      flash[:notice] = "Task created."
    else
      flash[:error] = "There are errors"
    end
    redirect_to :back#program_pitch_milestones_path(@program, @pitch)
  end

  def complete
    @task = Task.find(params[:id])
     if @task.task_type == "system_task"
       @task.completed_tasks.create!(:user_id => current_user.id.to_s, :completed => true, :date => Date.today)
     elsif @task.event_record_id
       Task.where(description: @task.description, user_id: @task.user_id, event_record_id: @task.event_record_id).each {|task| task.update_attribute("complete", !task.complete)}
     else
      @task.complete!
     end
    @program.activity_feeds.create(:type=>"pitch_task_completed", :user_id => current_user.id, :pitch_id=> params[:pitch_id], :task_id => @task.id)
    redirect_to program_pitch_milestones_path(@program, @pitch)
  end

  def destroy
    task = Task.find(params[:id])
    task.destroy
    redirect_to :back
  end

  private

  def load_dependency
    @program = Program.find(params[:program_id])
    @pitch = @program.pitches.find(params[:pitch_id])
    # @milestone = @pitch.milestones.find(params[:milestone_id])
  end

  def check_task
   if params[:task][:task_option2].present?
      params[:task][:task_type] = "system_task"
    end
  end
end
