namespace :default do
  desc "[FIX] Creates phases for existing custom fields"
  task :targets => :environment do
    Program.each do |program|
      Targetting.create_default_targets(program.id)
    end
  end
end