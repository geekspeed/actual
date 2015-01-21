namespace :app do

  namespace :pitch_phases do

    desc "Destroying inactive pitch phases"
    task :destroy => :environment do
      pitches = Pitch.all.map(&:id)
      PitchPhase.nin(:pitch_id => pitches).destroy
    end

  end

end