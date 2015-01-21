class EditPitchFieldController < ApplicationController
  before_filter :load_program

  def toggle_edit_status
    pitch = @program.pitches.find(params[:pitch_id])
    pitch.toggle_editing!
    redirect_to :back
  end

  private

  def load_program
    @program = Program.find(params[:program_id])
  end
end
