namespace :fix do
  desc "[FIX] Creates phases for existing custom fields"
  task :create_phases => :environment do
    App::CustomFields::Models::CustomField.skip_callback(:save, :before, :build_options)
    Pitch.custom_fields_with_anchor("pitch").each do |field|
      if field.attributes.has_key? "phase" and field.phases.empty?
        field.update_attribute("phases", field.phase)
      end
    end
    App::CustomFields::Models::CustomField.set_callback(:save, :before, :build_options)
  end
end