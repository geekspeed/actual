namespace :fix do
  task :change_company_name => :environment do
    program = Program.find("5385def223b5eae985000011")
    custom_field = User.custom_fields.where(:code => "company_name", :program_id => program.id.to_s).first
    if custom_field.present?
      custom_field.update_attributes(:code => "#{custom_field.code}#{custom_field.id}")
      users =User.or(:"_participant" => program.id.to_s).or(:"_mentor" => program.id.to_s).or(:"_panellist" => program.id.to_s)
      .or(:"_selector" => program.id.to_s).or(:"_awaiting_participant" => program.id.to_s).or(:"_awaiting_mentor" => program.id.to_s)
      users.each do |user|
        field = user.custom_fields["company_name"]
        if field.present?
          user.custom_fields[custom_field.code] = user.custom_fields.delete("company_name")
          user.save!
        end
      end
    end
  end
end