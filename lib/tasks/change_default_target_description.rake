namespace :change do
  desc "[FIX] Creates phases for existing custom fields"
  task :default_targets_description => :environment do
    Program.each do |program|
      participant = Semantic.translate(program, "role_type:participant")
      project = Semantic.translate(program, "pitch")
      
      target = program.targettings.where(role: "Innovators", is_default: true).first
      if target
        target.update_attributes(explaination: "All #{participant} without a #{project}")
      end
    end
  end
end