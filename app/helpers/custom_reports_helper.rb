module CustomReportsHelper

  def entity_fields(type)
    if type == "Project"
      Pitch.custom_fields.where(program_id: context_program).map{|m| [m.label, m.id]}.uniq
    elsif type == "Participant"
      User.custom_fields.where(program_id: context_program).map{|m| [m.label, m.id]}.uniq
    else
      []
    end
  end

  def get_elements(type)
    case type
    when "Project"
      context_program.pitches
    when "Participant"
      User.in(:"_participant" => context_program.id.to_s)
    else
      context_program
    end
  end

end
