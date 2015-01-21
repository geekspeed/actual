module DashboardHelper

  
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def faqs
    faqs_for_current_page = need?(["company_admin", "program_admin"], current_organisation) ? context_program.faqs : context_program.faqs.in(role_code: current_user.roles_string_for(context_program))
    if controller_name == "dashboards" and action_name == "show"
      faqs_for_current_page.where(relevant_page: "community_page")
    elsif controller_name == "dashboards" and action_name == "people" and params[:code] == "mentor"
      faqs_for_current_page.where(relevant_page: "mentors_page")
    elsif controller_name == "dashboards" and action_name == "people" and params[:code] == "participant"
      faqs_for_current_page.where(relevant_page: "applicants_page")
    elsif controller_name == "pitches" and action_name == "show"
      faqs_for_current_page.where(relevant_page: "pitch_detail_page")
    elsif controller_name == "milestones" and action_name == "index"
      faqs_for_current_page.where(relevant_page: "milestone_page")
    elsif controller_name == "pitches" and action_name == "feeds"
      faqs_for_current_page.where(relevant_page: "project_feed_page")
    elsif controller_name == "documents" and action_name == "index"
      faqs_for_current_page.where(relevant_page: "documents_page")
    elsif controller_name == "feedbacks" and action_name == "index"
      faqs_for_current_page.where(relevant_page: "feedback_page")
    elsif controller_name == "pitches" and action_name == "team"
      faqs_for_current_page.where(relevant_page: "team_page")
    elsif controller_name == "community_feeds" and action_name == "index"
      faqs_for_current_page.where(relevant_page: "activity_page")
    else
      []
    end
  end

  def show_pitch_rating(pitch, matrix, star_system)
    calculate = star_system ? :rating : :points
    if matrix == "overall" or matrix == nil
      pitch[calculate]
    else
      pitch.pitch_ratings.where(matrix_id: matrix).first.try(calculate)
    end
  end

  def remind_survey? survey
   case survey.target_audience
      when "Projects"
        check = false
        @pitches.each do|pitch|
          check = true if pitch.team?(current_user)
        end
        return check
      when "Participants"
        check = need?(["participant"], context_program)
      when "Mentors"
        check = need?(["mentor"], context_program)
    end
    check
  end

  def show_reminder_lightbox?
     check = false
     Survey.all.each{|survey| check = true if (survey_incomplete?(survey) and remind_survey?(survey))}
     check
  end
end
