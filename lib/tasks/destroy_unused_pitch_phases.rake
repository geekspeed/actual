namespace :fix do
  desc "Deleting unused pitch phases"

  task :destroy_unused_pitch_phases => :environment do
    pitches = Pitch.all.map(:id)
    PitchPhase.each do |pp|
      unless pitches.include?(pp.pitch_id)
        pp.destroy
      end
    end
  end
end