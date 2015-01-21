class PhasesController < ApplicationController

  before_filter :load_program

  def index
    @workflows = @program.workflows.on
    @current_phase = params[:phase].present? ? @program.workflows.
      find(params[:phase]) : @workflows.first
    if  !@current_phase.nil? && !@current_phase.code.nil?
      if @current_phase.code == "draft_pitch"
        pre_application_phase
      elsif @current_phase.code == "publish_pitch"
        application_phase
      elsif @current_phase.code == "shortlisting"
        shortlist_phase
      elsif @current_phase.code == "winner_selection"
        winner_selection_phase
      end
    end
  end

  def pre_application_phase
    program_id = @program.id.to_s
    @selectors = User.any_of(:"_invited_selector".in => [program_id])
      .any_of(:"_selector".in => [program_id])
    @panellists = User.any_of(:"_invited_panellist".in => [program_id])
      .any_of(:"_panellist".in => [program_id])
    @mentors = User.any_of(:"_invited_mentor".in => [program_id])
      .any_of(:"_mentor".in => [program_id])
    # render :template => "phases/pre_application"
  end

  def application_phase
    program_id = @program.id.to_s
    @registered_applicants = User.in("_participant" => [program_id])
    @not_registered_applicants = User.in("_invited_participant" => [program_id])

    @registered_mentors = User.in("_mentor" => [program_id]).count
    @not_registered_mentors = User.in("_invited_mentor" => [program_id]).count

    @pitches = @program.pitches
    @applicants_without_pitches = @registered_applicants.count - @pitches.collect(&:user_id).uniq.size

    @pitch_with_mentors = @pitches.select{|pitch| pitch.mentors.present? }
    @pitch_without_mentors = @pitches.select{|pitch| pitch.mentors.blank? }

    # render :template => "phases/application"
  end

  def shortlist_phase
    @selectors = User.selectors(@program.id.to_s)
  end

  def winner_selection_phase
    @selectors = User.selectors(@program.id.to_s)
  end

  def program_phase
    @pitches = @program.pitches
    @pitches_with_documents = @pitches.select{|p| p.documents.present? }
    @pitches_without_documents = @pitches.select{|p| p.documents.blank? }
    @documents = PitchDocument.in(:pitch_id => @program.pitch_ids)
    @approved_documents = @documents.select{|d| d.approved_by_mentors.present? }
    @unapproved_documents = @documents.select{|d| d.approved_by_mentors.blank? }
    # render :template => "phases/program_phase"
  end

  def closed_phase
  end

  def remind
    @user = User.find(params[:user_id])
    if @user.invited_for?(params[:code], @program)
      User.prelaunch_invitation_mail(@user.email, @program, params[:code],params[:subject],params[:message])
    end
    redirect_to :back
  end

  def message_all
    @users = User.in("_#{params[:code]}" => @program.id.to_s)
    d(@users.each{|u| u.inspect})
    redirect_to :back
  end

  def task_manager
    if @task_manager.persisted? ? 
      @task_manager.update_attributes(params[:progress_task_manager]) : 
      @program.build_progress_task_manager(params[:progress_task_manager]).save
      flash[:notice] = "Task manager saved successfully"
      redirect_to :back
    else
      flash[:notice] = "There are errors"
      redirect_to :back
    end
  end

  def manage
    @workflows = @program.workflows.on
  end

  def transition
  end

  private

  def load_program
    @program = Program.find(params[:program_id])
    @task_manager = @program.progress_task_manager.try(:persisted?) ? @program.progress_task_manager : 
      @program.build_progress_task_manager
  end

end
