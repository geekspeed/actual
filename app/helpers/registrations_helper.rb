module RegistrationsHelper

  def profile_custom_fields(user, program, field_name)
    App::CustomFields::Models::CustomField.for_class(User).where(:code.in => user.custom_fields.keys, program_id: program.try(:id), private_to_team:false, position: field_name)
  end

  def private_custom_fields(user, program)
    App::CustomFields::Models::CustomField.for_class(User).where(:code.in => user.custom_fields.keys, program_id: program.try(:id), private_to_team:true)
  end

end
