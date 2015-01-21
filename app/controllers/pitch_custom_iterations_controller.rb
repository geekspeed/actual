class PitchCustomIterationsController < ApplicationController
  before_filter :load_dependency

  def create
    unless params["#{@custom_field.try(:id)}_upload"].blank?
      params["changed_iteration_value"] = upload_custom_field(params["#{@custom_field.try(:id)}_upload"], @pitch, @custom_field)
      flash.keep[:notice] = @pitch.errors.full_messages.first
      redirect_to :back and return unless @pitch.errors.blank?
    end
    unless params["#{@custom_field.try(:id)}_gallery"].blank?
      params["#{@custom_field.try(:id)}_gallery"] = params["#{@custom_field.try(:id)}_gallery"].collect{|p| p if ["image/png","image/jpg","image/jpeg"].include?(p.content_type)}.compact
      params["changed_iteration_value"] = gallery_custom_field(params["#{@custom_field.try(:id)}_gallery"], @pitch, @custom_field)
      flash.keep[:notice] = @pitch.errors.full_messages.first
      redirect_to :back and return unless @pitch.errors.blank?
    end
    @iteration = @pitch.custom_iterations.build(params[:pitch_custom_iteration])
    @iteration.user = current_user
    @iteration.program = @program
    if @iteration.save
      @pitch.custom_fields[@custom_field.code] = params["changed_iteration_value"]
      @pitch.save
      flash[:notice] = "Iteration saved"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  private

  def load_dependency
    @program = Program.find(params[:program_id])
    @pitch = @program.pitches.find(params[:pitch_id])
    @custom_field = Pitch.custom_fields_with_anchor("pitch").where(id: params["pitch_custom_iteration"]["custom_field_id"]).first
  end

  def upload_custom_field (action_dispact, pitch, custom_field)
    if custom_field.options.blank? || (!custom_field.options.blank? and custom_field.options.include?(action_dispact.original_filename.split('.').try(:last).try(:downcase)))
      file_upload = custom_field.upload_file.find_or_initialize_by(for_class: Pitch, class_id: pitch.id )
      file_upload.update_attributes(:avatar => action_dispact)
      return file_upload.try(:avatar).try(:url)
    else
      pitch.errors[:base] << "For Field #{custom_field.code} only #{custom_field.options} file type supported"
    end
  end

  def gallery_custom_field (action_dispacts, pitch, custom_field)
    file_urls = []
    action_dispacts.each do |action_dispact| 
      if custom_field.options.blank? || (!custom_field.options.blank? and custom_field.options.include?(action_dispact.original_filename.split('.').try(:last).try(:downcase)))
        file_upload = custom_field.upload_file.create(for_class: Pitch, class_id: pitch.id )
        file_upload.update_attributes(:avatar => action_dispact)
        file_urls << file_upload.try(:avatar).try(:url)
      else
        pitch.errors[:base] << "For Field #{custom_field.code} only #{custom_field.options} file type supported"
      end
    end
    return file_urls
  end

end