class WorkflowsController < ApplicationController

  before_filter :load_program

  def index
    @workflows = @program.workflows
  end

  def create
    params[:workflow].each do |key, workflow|
      if workflow[:id].present?
        phase = @program.workflows.find(workflow.delete(:id))
        phase.update_attributes(workflow)
        if workflow["workflow_milestone"].present?
          add_milestone(phase,workflow["workflow_milestone"])
        end
      else
        next if workflow[:phase_name].blank?
        @program.workflows.create!(workflow)
      end
    end
    redirect_to :back
  end

  def toggle_status
    @workflow = @program.workflows.find(params[:id])
    @workflow.toggle!
    redirect_to :back
  end

  def achieved
    @workflow = @program.workflows.find(params[:id])
    @pitch = @program.pitches.find(params[:pitch_id])
    @workflow.complete!(@pitch, current_user)
    redirect_to !@workflow.target_url.blank? ? @workflow.target_url : :back
  end

  def undo
    @workflow = @program.workflows.find(params[:id])
    @pitch = @program.pitches.find(params[:pitch_id])
    @workflow.phase_for(@pitch).destroy
    redirect_to :back
  end

  def delete_milestone
    @workflow = @program.workflows.find(params[:id])
    @workflow.workflow_milestone.destroy
    redirect_to :back
  end

  private

  def load_program
    @program ||= Program.find(params[:program_id])
  end

  def add_milestone(phase,workflow_milestone)
    phase.workflow_milestone.present? ? phase.workflow_milestone.update_attributes(workflow_milestone) : phase.workflow_milestone.create(workflow_milestone)
  end         
end
