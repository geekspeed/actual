namespace :fix do
  desc "[FIX] Patches custom field phases"
  task :patching_pitch_custom_fields_with_phase => :environment do
    App::CustomFields::Models::CustomField.skip_callback(:save, :before, :build_options)
    Pitch.custom_fields_with_anchor("pitch").each do |field|
      unless field.attributes.has_key? "phase"
        field.update_attribute("phase", "Draft Pitch")
      end
    end
    App::CustomFields::Models::CustomField.set_callback(:save, :before, :build_options)
  end
end