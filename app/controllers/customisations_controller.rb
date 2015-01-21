class CustomisationsController < ApplicationController

  before_filter :load_program

  def new
    @anchor = params[:ankor]
    @klass = params[:referee] || "User"
    @custom_fields = @anchor.present? ? @klass.constantize.
      custom_fields_with_anchor(@anchor) : @klass.constantize.custom_fields
    @custom_fields = @custom_fields.where(program_id: @program.id, parent_id: "")
  end

  def create
    @anchor = params[:ankor]
    @klass = params[:referee] || "User"
    @custom_fields = @anchor.present? ? @klass.constantize.
      custom_fields_with_anchor(@anchor) : @klass.constantize.custom_fields
    @custom_fields = @custom_fields.where(program_id: @program.id)

    if params[:context_message]
      @program.context_messages.find_or_create_by(anchor: @anchor).update_attributes(context_message: params[:context_message])
    end

    params[:custom_fields].each do |field|
      option_attributes = field.delete("options_fields")
      option_attributes ||= []
      parent_field = save_field field
      destroy_dependent_option_fields parent_field
      option_attributes.each do |option_field|
        save_field option_field, parent_field.id
      end
    end if params[:custom_fields]
    create_pitch_semantics(params[:semantics])
    redirect_to :back
  end

  def delete_custom_fields
    field = App::CustomFields::Models::CustomField.where(id: params[:field_id]).first
    destroy_dependent_option_fields field
    field.destroy
    render :json => true
  end

  def remove_basic_fields
    program = Program.where(id: params[:program_id]).first
    basic_field = BasicFieldToggle.find_or_create_by(program_id: program.id, user_type: params[:type])
    basic_field.update_attribute(params[:data], !basic_field[params[:data]])
    render :json => true
  end

  private

  def load_program
    @program ||= Program.find(params[:program_id])
  end
  
  def save_field field, parent_field_id = ""
    if field[:id].present?
      cf = App::CustomFields::Models::CustomField.find(field[:id])
      field[:required] ||= false
      field[:private_to_team] ||= false
      field[:use_as_filter] ||= false
      cf.update_attributes(field.merge({
        for_class: @klass, anchor: @anchor, program_id: @program.id, parent_id: parent_field_id
      }))
    else
      cf = App::CustomFields::Models::CustomField.new(field.merge({
        for_class: @klass, anchor: @anchor, program_id: @program.id, parent_id: parent_field_id
      }))
      cf.save
    end
    return cf
  end

  def destroy_dependent_option_fields parent_field
    App::CustomFields::Models::CustomField.where(program_id: @program.id.to_s, parent_id: parent_field.id.to_s).delete
  end

  def create_pitch_semantics(pitch_semantics)
    pitch_semantics.each do |key, semantic|
      Semantic.for_program(@program.id).find_or_create_by(key: 
        key).update_attributes(semantic)
    end if pitch_semantics
  end

end