module CoursesHelper
  def course_deadline(course)
    deadline = course.course_modules.map{|p| p.module_activities.where(:deadline_option => true)}.flatten.sort_by(&:deadline).try(:last).try(:deadline)
    if !deadline.blank?
      if deadline < Date.today
        return "Expired"
      else
        return time_ago_in_words(deadline) 
      end
    else
      return "No"
    end
  end

  def course_duration(course)
    course_modules = course.course_modules
    @time_taken = 0
    duration = course_modules.map(&:module_activities).flatten
    duration.each do |d|
      timings = d.time_taken.split(":")
      @time_taken += timings[0].to_i.hour
      @time_taken += timings[1].to_i.minutes
    end
    minutes = (@time_taken / 60) % 60
    hours = @time_taken / (60 * 60)
    if !duration.blank?
    time_cal_in_point(hours,minutes)
    return @duration
    else
      return ""
    end
  end

  def module_deadline(course_module)
    deadline = course_module.try(:module_activities).where(:deadline_option => true).sort_by(&:deadline).try(:last).try(:deadline)
    if !deadline.blank?
      if deadline < Date.today
        return "Expired"
      else
        return time_ago_in_words(deadline) 
      end
    else
      return "No"
    end
  end

  def module_duration(course_module)
    @time_taken = 0
    duration = course_module.try(:module_activities)
    duration.each do |d|
      timings = d.time_taken.split(":")
      @time_taken += timings[0].to_i.hour
      @time_taken += timings[1].to_i.minutes
    end
    minutes = (@time_taken / 60) % 60
    hours = @time_taken / (60 * 60)
    if !duration.blank?
    time_cal(hours,minutes)
    return @duration
    else
      return ""
    end
  end
  
  def activity_deadline(activity)
    deadline = activity.deadline
    if activity.deadline_option == true
      if deadline < Date.today
        return "Expired"
      else
        return time_ago_in_words(deadline) 
      end
    else
      return "No"
    end
  end

  def activity_duration(activity)
    time_taken = activity.try(:time_taken)
    timings = time_taken.split(":")
    hours = timings[0]
    minutes = timings[1]
    time_cal(hours,minutes)
    return @duration
  end

  def time_cal(hours,minutes)
    @duration =""
    if (hours!=" 0") && (hours!=0) && (hours!="00") && !hours.blank?
      @duration +=" #{hours} hour"
    end
    if (minutes!="00") && (minutes!=0) && !minutes.blank?
       @duration +=" #{minutes} min"
    else      
      @duration +=" 00 min"
    end
  end

  def time_cal_in_point(hours,minutes)
    @duration =""
    if (hours!=" 0") && (hours!=0) && (hours!="00") && !hours.blank?
      @duration +="#{hours}"
    end
    if (minutes!="00") && (minutes!=0) && !minutes.blank?
      @duration +=".#{minutes}"
    else      
      @duration +=".00"
    end
  end


  def course_attachment(obj)
    if obj[0].media.html.nil?
      link_to obj[0].url, obj[0].url, :target => "_blank"
    else
      return "<div class='video-container'>#{raw obj[0].media.html}</div>".html_safe
    end
  end

  def course_tags(course)
    tags_count =""
    course_modules = @course.course_modules
    course_activities = course_modules.map{|p| p.module_activities}.flatten
    tags = (course_activities.map{|p| p.course_module}.uniq.flatten.map{|p| p.keywords}.flatten + course_modules.map{|p| p.module_activities.map(&:keywords)}.flatten) 
    count = Hash.new(0)
    tags.each do |v|
      count[v] += 1
    end
    count.each do |k, v|
      tags_count +=  "<a href='#' data-tag='#{k.gsub(" ","-")}' class='no_content_flash course-tag-container course-tag'>#{k}<div class='numberCircle'>#{v}</div></a>"
    end
    if !tags.blank?
      return "<a href='#' data-tag='All' id='select-all-modules' class='no_content_flash course-tag-container course-tag'>All<div class='numberCircle'>#{course_modules.count+course_activities.count}</div></a> #{tags_count}".html_safe
    else
      return "<i>Course does not have any tags.</i>".html_safe
    end 
  end

  def activity_status(activity)
    if !activity.activity_performances.where(:status => true, :user_id => current_user.id, :pitch_id=>params[:pitch_id]).blank?
      '<a href="#" title="Completed" class="btn btn-xs btn-success" style="border:0px;margin-left:10px;font-weight:normal;text-transform:capitalize;background:green;">Completed</a>'.html_safe
    end 
  end  

  def activity_status_class(activity)
    activity_performance = activity.activity_performances.where(:user_id => current_user.id, :pitch_id=>params[:pitch_id]).try(:first)
    if activity_performance.blank?
      'blue_indi'
    elsif (activity.activity_project_fields.blank? && activity.try(:action).blank?) && activity_performance.video_watch_status
      'green_indi'
    elsif activity_performance.status && activity_performance.video_watch_status
      'green_indi'
    else
      'yellwo_indi'
    end 
  end   

  def module_status_class(course_module)    
    module_activities = course_module.try(:module_activities)
    activity_performances = ActivityPerformance.where(:module_activity_id.in => module_activities.map(&:id), :user_id=>current_user, :pitch_id=>params[:pitch_id])
    activity_performances_completed = activity_performances.collect{|p| p if (((p.module_activity.try(:activity_project_fields).blank? && p.module_activity.try(:action).blank?) && p.video_watch_status) || (p.status && p.video_watch_status))}.flatten.compact
    if activity_performances.blank?
      'blue_indi'
    elsif activity_performances_completed.count < module_activities.count
      'yellwo_indi'
    elsif activity_performances_completed.count == module_activities.count
      'green_indi'
    end 
  end

  def count_module_number(course_data, module_data)
    "Module #{course_data.course_modules.index(module_data)+1}"
  end   

  def count_activity_number(module_data, activity_data)
    "Activity #{module_data.module_activities.index(activity_data)+1}"
  end 
  
  def activity_watched
    duration = 0
    video_watch_status = true
    if !@pitch.blank?
      activity_performance = @activity.activity_performances.where(:user_id=>current_user.id, :pitch_id=>@pitch.id, :module_activity_id=>@activity.id).try(:first)
      if activity_performance.present?
        activity_performance.update_attributes(:video_watch_duration => duration,:video_watch_status => video_watch_status)
      else 
        @activity.activity_performances.create(:user_id=>current_user.id, :pitch_id=>@pitch.id, :video_watch_duration => duration, :video_watch_status => video_watch_status)
      end
    end
  end

   def activity_completed(activity)
    activity_performance = activity.activity_performances.where(:user_id => current_user.id, :pitch_id=>params[:pitch_id]).try(:first)
    if activity_performance.blank?
      false
    elsif (activity.activity_project_fields.blank? && activity.try(:action).blank?) && activity_performance.video_watch_status
      true
    elsif activity_performance.status && activity_performance.video_watch_status
      true
    else
      false
    end 
  end   
end
