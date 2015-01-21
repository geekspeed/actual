class PitchInvitationsController < ApplicationController
  before_filter :load_dependency

  def accept_invitation
    invitation = PitchInvitation.where(id: params[:id]).first
    if invitation.present? and current_user.id.to_s == invitation.invitee_id
      @pitch.add_to_mentors! invitation.invitee_id
      mentor = Semantic.translate(@pitch.program, "role_type:mentor")
      project = Semantic.translate(@pitch.program, "pitch")
      flash[:notice] = "Congratulation! You are now a " + mentor + " for this " + project
      Resque.enqueue(App::Background::InviteMentorResponse, @pitch.id, invitation.invitee_id, "Accepted", @pitch.program_id, @pitch.program.class.to_s)
      invitation.delete
    else
      flash[:notice] = "Invalid token"
    end
    if params[:from_profile].present?
      redirect_to :back
    else
      redirect_to root_url
    end
  end

  def decline_invitation
    invitation = PitchInvitation.where(id: params[:id]).first
    if invitation.present? and current_user.id.to_s == invitation.invitee_id
      mentor = Semantic.translate(@pitch.program, "role_type:mentor")
      project = Semantic.translate(@pitch.program, "pitch")
      flash[:notice] = "Sorry you can not be a " + mentor + " for this " + project
      Resque.enqueue(App::Background::InviteMentorResponse, @pitch.id, invitation.invitee_id, "Decline", @pitch.program_id, @pitch.program.class.to_s)
      invitation.delete
    else
      flash[:notice] = "Invalid token"
    end
    if params[:from_profile].present?
      redirect_to :back
    else
      redirect_to root_url
    end
  end

  private

  def load_dependency
    @program = Program.find(params[:program_id])
    @pitch = @program.pitches.find(params[:pitch_id])
  end
end