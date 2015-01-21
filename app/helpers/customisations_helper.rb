module CustomisationsHelper

  def active_phase(program)
    program.workflows.where(on: true) << program.workflows.new(:code => "all", :phase_name => "Link To All")
  end

  def show_basic_field(program, attr, type)
    if program and program.try(:basic_field_toggles).empty?
      return true
    elsif program
      basic_field = program.basic_field_toggles.where(user_type: type).first
      basic_field ? basic_field[attr] : true
    else
      true
    end
  end

end
