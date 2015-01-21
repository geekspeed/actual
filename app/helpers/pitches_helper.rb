module PitchesHelper

  def mentor_applications_open?
    return false if [context_program, @pitch].collect(&:blank?).any?
    current_user.mentor?(context_program) &&
     !@pitch.mentor?(current_user) && !@pitch.close_mentors?
  end

  def feedback_count(pitch)
    if pitch.team_and_mentor?(current_user)
      pitch.feedbacks.count
    else
      pitch.feedbacks.where(private: false).count
    end
  end

  def show_pitch_field(pitch, custom_field, current_organisation, context_program, current_user)
    unless (pitch.pitch_privacies.find_or_initialize_by(custom_field_id: custom_field.id).try(:private) and !need?(["company_admin", "program_admin"], current_organisation) and !need?(["selector", "panellist"], context_program) and !pitch.try(:team_and_mentor?, current_user))
      return true
    else
      return false
    end
  end

  def pitch_visibility_to_team(user, custom_field, pitch, current_organisation)
    unless custom_field.private_to_team
      return true
    else
      return true if (need?(["selector", "panellist"], pitch.try(:program)) or need?(["company_admin", "program_admin"], current_organisation) )
      return pitch.try(:team_and_mentor?, user)
    end
  end

  def urgent_tasks(pitch)
    tasks = Task.in(milestone_id: pitch.milestones.map(&:id)).where(:deadline => Date.today..Date.today + 3.day, complete: false).asc(:deadline).limit(4)
    if tasks.count < 4
      tasks = Task.in(milestone_id: pitch.milestones.map(&:id)).where(complete: false, :deadline.ne => nil).asc(:deadline).limit(4)
    end
    return tasks
  end

  def color_scheme_class(task)
    if task.complete
      "deliver"
    else
      if task.deadline
        time_limit = task.deadline.mjd - Date.today.mjd
        case time_limit.to_i
          when (-100..-1)
            "late"
          when 0..2
            "later"
          else
            "done"
        end
      else
        "now"
      end
    end
  end
  
  def color_scheme(task)
    if task.complete
      "background-color: #949494;color:white; font-weight:bold;"
    else
      if task.deadline
        time_limit = task.deadline.mjd - Date.today.mjd
        case time_limit.to_i
          when (-100..-1)
            "background-color: #D2322D;color:white; font-weight:bold;"
          when 0..2
            "background-color: #ED9C28;color:white; font-weight:bold;"
          else
            "background-color: #47A447;color:white; font-weight:bold;"
        end
      else
        "background-color: #428BCA;color:white; font-weight:bold;"
      end
    end
  end

  def color_type(task)
    if task.complete
      "task-delivered"
    else
      if task.deadline
        time_limit = task.deadline.mjd - Date.today.mjd
        case time_limit.to_i
          when (-100..-1)
            "task-extreme"
          when 0..2
            "task-warning"
          else
            "task-completed"
        end
      else
        "task-new"
      end
    end
  end

  def survey_visible? survey
   case survey.target_audience
      when "Projects"
        check = @pitch.team?(current_user)
      when "Participants"
        check = need?(["participant"], context_program)
      when "Mentors"
        check = need?(["mentor"], context_program)
    end
    check and survey_incomplete?(survey) and survey.visible?("todo")
  end
  
  def survey_incomplete? survey
    survey.total_audience.include?(current_user.id) and !survey.audience_completed_survey.include?(current_user.id) if current_user
  end

  def workspace_sementic(sementic_attr,static_name)
    workspace = context_program.try(:workspace)
    !workspace.try(sementic_attr).blank? ? workspace.try(sementic_attr) : static_name
  end

  def pitch_team_members(pitch)
    members = (User.find(pitch.members) << User.find(pitch.mentors)).flatten.uniq.first(2)
  end
  
  def show_button(pitch, program, user)
    if controller_name == "pitches" and !pitch.team?(user) and program.workspace.to_do_list_join_this_team and  user.role?("participant", program.id.to_s)
      return true
    else
      return false
    end
  end
end
