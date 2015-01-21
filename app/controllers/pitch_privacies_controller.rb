class PitchPrivaciesController < ApplicationController

  before_filter :load_program

  def change_privacy_of_pitch
    pitch = @program.pitches.find(params[:pitch_id])
    pitch.pitch_privacies.find_or_initialize_by(custom_field_id: params[:custom_field_id]).update_attributes(:private => params[:private])
    respond_to do |format|
      format.json { head :no_content }
    end
  end


  private

  def load_program
    @program = Program.find(params[:program_id])
  end

end
