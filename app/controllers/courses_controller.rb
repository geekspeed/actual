class CoursesController < ApplicationController
include CoursesHelper
before_filter :load_program

  def index
    @course = @program.course
    if !@program.course_setting.blank?
      @course_setting = @program.course_setting
    end
    if !@course.blank?
      @modules = @course.course_modules
    end
  end

  def general_controls
    if !@program.course_setting.blank?
      @course_setting = @program.course_setting.update_attributes(params[:setting])
    else
      @course_setting = @program.build_course_setting(params[:setting])
      @course_setting.save
    end
  end
  
  def course_preview
    load_course
    if !@course.blank?
      @modules = @course.course_modules
    end
  end

  def show
    @custom_fields = custom_fields
    @pitch = @program.pitches.find(params[:pitch_id])
    load_course
    if !@course.blank?
      @modules = @course.course_modules
      @activities = @modules.map(&:module_activities).flatten
      if !@activities.blank?
        @activity = show_activity_to_perform(@activities)
        @activity_performance = @activity.activity_performances.where(:user_id => current_user.id, :pitch_id=>params[:pitch_id]).try(:first) 
        @next_activity = @activities[@activities.index(@activity).try(:next)]
      end
    end
    render layout: "layouts/application_new_design"
  end

  def course_overview
    load_course
  end

  def create
    if !@program.course.blank?
      @course = @program.course.update_attributes(params[:course])
    else
      @course = @program.build_course(params[:course])
      @course.save
      @modules = @course.course_modules
    end
    redirect_to :back
  end

  def new_module
    load_course
    @module = @course.course_modules.build
    @action_path = polymorphic_path([@program, @course, :create_module])
  end

  def create_module
    load_course
    @course.course_modules.create(params[:course_module])
    redirect_to :back
  end

  def delete_module
    load_module
    @module.destroy(params[:module_id])
    redirect_to :back
  end

  def edit_module
    @page="edit_module"
    load_course
    load_module
    @action_path = polymorphic_path([@program, @course, @module, :update_module])
  end

  def update_module
    load_course
    load_module
    @module.keywords = []
    @module.update_attributes(params[:course_module])
    if @module.save
      redirect_to :back
    end
  end

  def module_detail
    load_course
    load_module
  end

  def new_activity
    load_course
    load_module
    @activity = @module.module_activities.build
    @activity.study_materials
    @activity.activity_project_fields.build
    @action_path = polymorphic_path([@program, @course, @module, :add_activity])
    @project_fields = custom_fields
    @activity_project_fields = []
  end

  def add_activity
    load_module
    (params[:module_activity][:action] = "") if params[:module_activity][:action] == "<p><br></p>"
    @module.module_activities.create(params[:module_activity])
    redirect_to :back
  end

  def show_activity
    load_course
    load_module
    load_activity
    @project_fields = custom_fields
  end

  def study_materials
    load_course
    load_module
    load_activity
    activity_performance_status_track
  end

  def show_exercise
    load_course
    load_module
    load_activity
    activity_performance_status_track
    @project_fields = custom_fields
    @pitch = Pitch.find(params[:pitch_id])
  end

  def start_activity
    load_course
    load_module
    load_activity
    @pitch = Pitch.find(params[:pitch_id])
        @project_fields = custom_fields

    activity_performance_status_track
    if !@course.blank?
      @modules = @course.course_modules
      @activities = @modules.map(&:module_activities).flatten
      if !@activities.blank?
        @next_activity = @activities[@activities.index(@activity).try(:next)]
        @prev_activity = @activities[@activities.index(@activity).try(:pred)] if @activities.index(@activity).try(:pred) > -1
      end
    end
    @activity_performance = current_user.activity_performances.where(:pitch_id=>params[:pitch_id], :module_activity_id=>@activity.id).try(:first)
    render layout: "layouts/course_play_page"
  end  

  def activity_video_watch
    load_course
    load_module
    load_activity
    if params[:video_watch_status].blank?
      activity_video_duration(params[:duration])
    else
      activity_video_watched(params[:duration],params[:video_watch_status])
    end
  end

  def show_activity_material
    load_course
    load_module
    load_activity    
    @study_material = StudyMaterial.find(params[:study_material_id])
  end

  def edit_activity
    load_course
    load_module
    load_activity
    @page = "edit_activity"
    @action_path = polymorphic_path([@program, @course, @module, @activity, :update_activity])
    @custom_fields = custom_fields
    @activity_project_field_ids = @activity.activity_project_fields.map(&:custom_field_id)
    @activity_project_fields = custom_fields.where(:id.in => @activity_project_field_ids)
    @project_fields = @custom_fields - @activity_project_fields
  end

  def update_activity
    load_activity
    @activity.keywords = []
    @activity.activity_project_fields.destroy_all
    (params[:module_activity][:action] = "") if params[:module_activity][:action] == "<p><br></p>"
    @activity.update_attributes(params[:module_activity])
    if @activity.save
      redirect_to :back
    end
  end

  def delete_activity
    load_activity
    @activity.destroy
    redirect_to :back
  end

  def delete_study_material
    @study_material = StudyMaterial.find(params[:study_material_id])
    @study_material.destroy
  end

  def activity_perform
    if !params[:pitch_id].blank?
      load_activity
      @pitch = Pitch.find(params[:pitch_id])
      if !params[:pitch].blank?
        project_fields = custom_fields
        activity_custom_fields = project_fields.where(:id.in => @activity.activity_project_fields.map(&:custom_field_id))
        activity_custom_fields.each do |activity_custom_field|
          custom_field_value = params[:pitch][:custom_fields][activity_custom_field.code]
          if !custom_field_value.blank?
            unless activity_custom_field.element_type != "file_upload"
              custom_field_value =  upload_custom_field(custom_field_value, @pitch, activity_custom_field)
              flash.keep[:notice] = @pitch.errors.full_messages.first
              redirect_to :back and return unless @pitch.errors.blank?
            end
            unless activity_custom_field.element_type != "gallery"
              custom_field_value = custom_field_value.collect{|p| p if ["image/png","image/jpg","image/jpeg"].include?(p.content_type)}.compact
              custom_field_value = gallery_custom_field(custom_field_value, @pitch, activity_custom_field)
              flash.keep[:notice] = @pitch.errors.full_messages.first
              redirect_to :back and return unless @pitch.errors.blank?
            end
            @pitch.custom_iterations.create(:program_id=>@program.id, :user_id => current_user.id, :custom_field_id=>activity_custom_field.id, :content=>(!@pitch.custom_fields[activity_custom_field.code].is_a?(Array) ? @pitch.custom_fields[activity_custom_field.code] : @pitch.custom_fields[activity_custom_field.code].join(" "))) if @pitch.custom_fields.keys.include?(activity_custom_field.code)
            @pitch.custom_fields[activity_custom_field.code] = custom_field_value
            @pitch.save
          end
        end
      end
      activity_performance = @activity.activity_performances.where(:user_id=>current_user.id, :pitch_id=>params[:pitch_id], :module_activity_id=>params[:activity_id]).try(:first)
      if activity_performance.present?
        activity_performance.update_attributes(:status=>true)
      else 
        @activity.activity_performances.create(:status => true, :user_id=>current_user.id, :pitch_id=>params[:pitch_id])
      end
    end
    next_activity = next_activity(@activity)
    if activity_completed(@activity) && !next_activity.blank?
      redirect_to start_next_activity(next_activity,params[:pitch_id])
    else      
      redirect_to :back
    end
  end

  def activity_notes
    activity_performance = ActivityPerformance.find(params[:id])
    activity_note = activity_performance.activity_notes.create(params[:activity_notes])
   
    respond_to do |format|
      format.json { render :json => {:id=>activity_note.id, :notes => activity_note.notes, :video_watch_duration=> notes_time_cal(activity_note.video_watch_duration), :video_watch_duration_in_sec => activity_note.video_watch_duration} }
    end
  end
  
  def update_activity_notes
    activity_note = ActivityNote.find(params[:activity_notes_id])
    activity_note.notes = params[:notes]
    activity_note.save
    respond_to do |format|
      format.json { render :json => {:id=>activity_note.id, :notes => activity_note.notes} }
    end
  end

  def delete_activity_notes
    activity_note = ActivityNote.find(params[:activity_notes_id])
    respond_to do |format|
      format.json { render :json => activity_note.destroy}
    end
  end

  def play_module
    load_course
    load_module
    if !@course.blank?
      @modules = @course.course_modules
    end
    @pitch = Pitch.find(params[:pitch_id])
    render layout: "layouts/course_play_page"
  end  

  def sort_activity
    @activities = load_module.module_activities
    @activities.each do |activity|
      activity.position = params[:display_order].index(activity.id.to_s) + 1
      activity.save  
    end
    respond_to do |format|
      format.json { render :json => true}
    end
  end  

  def task_reference_links
    load_course
    activity_refer = Hash.new
    if params[:activity_ids].present?
      params[:activity_ids].each do |activity_id| 
        activity = ModuleActivity.find(activity_id)
        activity_refer[activity_id] = polymorphic_url([@program, @course, activity.course_module, activity, :start_activity],:pitch_id=>params[:pitch_id])
      end
    end
    respond_to do |format|
      format.json { render :json => {activity_refer: activity_refer} }
    end
  end
  
  private

  def load_program
    @program ||= Program.find(params[:program_id])
  end

  def load_course
    @course ||= Course.find(params[:course_id])
  end

  def load_module
    @module ||= CourseModule.find(params[:module_id])
  end

  def load_activity
    @activity ||= ModuleActivity.find(params[:activity_id])
  end

  def custom_fields
    Pitch.custom_fields_with_anchor("pitch").where(program_id: @program.id)
  end

  def activity_performance_status_track
    if !params[:pitch_id].blank?
      activity_performance = @activity.activity_performances.where(:user_id=>current_user.id, :pitch_id=>params[:pitch_id], :module_activity_id=>params[:activity_id]).try(:first)
      if activity_performance.present?
        activity_performance.touch(:updated_at)
      else 
        @activity.activity_performances.create(:user_id=>current_user.id, :pitch_id=>params[:pitch_id])
      end
    end
  end

  def activity_video_duration(duration)
    if !params[:pitch_id].blank?
      activity_performance = @activity.activity_performances.where(:user_id=>current_user.id, :pitch_id=>params[:pitch_id], :module_activity_id=>params[:activity_id]).try(:first)
      if activity_performance.present?
        activity_performance.update_attributes(:video_watch_duration => duration)
      else 
        @activity.activity_performances.create(:user_id=>current_user.id, :pitch_id=>params[:pitch_id])
      end
    end
  end

  def activity_video_watched(duration,video_watch_status)
    if !params[:pitch_id].blank?
      activity_performance = @activity.activity_performances.where(:user_id=>current_user.id, :pitch_id=>params[:pitch_id], :module_activity_id=>params[:activity_id]).try(:first)
      if activity_performance.present?
        activity_performance.update_attributes(:video_watch_duration => duration,:video_watch_status => video_watch_status)
      else 
        @activity.activity_performances.create(:user_id=>current_user.id, :pitch_id=>params[:pitch_id], :video_watch_duration => duration, :video_watch_status => video_watch_status)
      end
    end
  end

  def show_activity_to_perform(activities)
    if !params[:activity_id].blank?
      activities.collect{|p| p if p.id.to_s==params[:activity_id]}.compact.try(:first)
    elsif !last_performed_activity_id.blank?
      ModuleActivity.find(last_performed_activity_id)
    else
      activities.try(:first)
    end 
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

  def start_next_activity(next_activity, pitch_id)
    polymorphic_path([@program, next_activity.try(:course_module).try(:course), next_activity.try(:course_module), next_activity, :start_activity],:pitch_id=>pitch_id)
  end

  def next_activity(activity)
    modules = activity.course_module.course.course_modules
    activities = modules.map(&:module_activities).flatten
    next_activity = activities[activities.index(activity).try(:next)]
    return next_activity
  end
end