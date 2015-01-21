class VotingSheetsController < ApplicationController

  before_filter :load_program

  def download
    Resque.enqueue(App::Background::RequestVotingSheet,current_user.try(:id) , @program.id, params[:pitch_selected], params[:pitch_id])
    flash[:notice] = "Your request for voting sheet is successfully submitted"
    redirect_to :back
  end

  private

  def load_program
    @program = Program.find(params[:program_id])
  end

end
