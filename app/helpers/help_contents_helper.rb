module HelpContentsHelper

  def show_help_content(program, custom_field_id, field_name, ankor)
      program.help_contents.for_custom_field(custom_field_id).find_or_initialize_by(field_name: field_name, text_for: params[:ankor])
  end

end