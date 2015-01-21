namespace :fix do
  desc "[FIX] Change class for mentors"
  task :change_class => :environment do
    Program.all.each do |program|
      program.pitches.each do |pitch|
        pitch.mentors = pitch.mentors.flatten.uniq.map(&:to_s)
        pitch.save
      end
    end
  end
end