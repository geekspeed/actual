class WhatField

  def self.participants(reporting,program,who_data)
    case reporting["what_field_1"] 
    when "Participants"
      case reporting["what_field_2"]
      when "number_of_participants"
        HowField.participants_participants_no_of_participants(reporting,program,who_data)
      end
    when "Organisations"
      case reporting["what_field_2"]
      when "number_of_organisations"
        participants_org = who_data.map(&:organisation).reject(&:blank?)
        HowField.participants_organisation_no_of_organisations(reporting,program,participants_org)
      end
    when "Projects"
      case reporting["what_field_2"]
      when "number_of_projects"
        participants = who_data.map(&:id)
        pitches = []
        pitches << program.pitches.where(:user_id.in => participants)
        participants.each do |participant|
          pitches << program.pitches.where(:members=>participant.to_s)
        end
        pitches = pitches.flatten.uniq
        HowField.participant_projects_no_of_projects(reporting,program,pitches)
      end
    when "Engagement"
      case reporting["what_field_2"]
      when "Engagement"
        case reporting["what_field_3"]
        when "Time spent on platform"
          time_spent = who_data.collect{|p| [p.id,((p.updated_at - p.created_at).to_i/1.day)]}
          HowField.participant_engagement_time_spent(reporting,program,time_spent)
        when "Average user session length"

        when "Number of likes"
          post_and_comments = CommunityFeed.feed_for_program(program.id, ["all"]).collect{|p| [p,p.comments]}.reject(&:blank?).flatten
          participants_likes = who_data.collect{|q| [q.id, post_and_comments.collect{|p| p.liked_by?(q)}.reject(&:blank?).count]}
          HowField.participant_engagement_no_of_likes(reporting,program,participants_likes)
        when "Number of comments"
          all_comments = CommunityFeed.feed_for_program(program.id, ["all"]).collect{|p| [p.comments,p.comments.collect{|p| p.children}]}.reject(&:blank?).flatten
          participants_comments = who_data.collect{|q| [q.id, all_comments.collect{|p| p.commented_by_id.to_s == q.id.to_s}.reject(&:blank?).count]}
          HowField.participant_engagement_no_of_comments(reporting,program,participants_comments)
        when "Number of posts on community feed" 
          community_feed_posts = CommunityFeed.feed_for_program(program.id, ["all"]).for_pitch(nil).reject(&:blank?).flatten
          participants_posts = who_data.collect{|q| [q.id, community_feed_posts.collect{|p| p.created_by_id.to_s == q.id.to_s}.reject(&:blank?).count]}
          HowField.participant_engagement_no_of_posts_on_community_feed(reporting,program,participants_posts)
        when "Number of events signed up to" 
        when "Number of responses to reminders"

        end
      end
    when "Learning"
      case reporting["what_field_2"]
      when "Formal"
        case reporting["what_field_3"]
        when "Number of modules completed"
          HowField.participants_learning_completed_modules(reporting,program,who_data)
        when "Number of activities completed"
          HowField.participants_learning_completed_activities(reporting,program,who_data)      
        when "Hours of content consumed"
          HowField.participants_learning_hours_consumed(reporting,program,who_data)      
        end
      when "Action"   
        case reporting["what_field_3"]
        when "Number of tasks completed"
          HowField.participants_learning_tasks_completed(reporting,program,who_data)
        when "Number of iterations"
          HowField.participants_no_of_iterations(reporting,program,who_data)
        when "Number of times feedback requested"
          HowField.participants_feedback_requested(reporting,program,who_data)
        when "Number of posts on project feed"
          HowField.participants_learning_posts_on_project_feed(reporting,program,who_data)
        end
      when "Social"
        case reporting["what_field_3"]
        when "Number of times feedback received"
          HowField.participants_feedback_requested(reporting,program,who_data)
        when "Number of times feedback given"
          HowField.participants_feedback_requested(reporting,program,who_data)
        end
      end
    when "Quality"
    when "Survey"
    end
  end

  def self.projects(reporting,program,who_data)
    case reporting["what_field_1"] 
    when "Participants"
      case reporting["what_field_2"]
      when "number_of_participants"
        participants_ids = who_data.map{|p| [p.members,p.user_id.to_s]}.flatten.uniq
        participants = User.participants(program.id.to_s).where(:id.in => participants_ids)
        HowField.project_participants_no_of_participants(reporting,program,participants)
      end
    when "Organisations"
      case reporting["what_field_2"]
      when "number_of_organisations"
        pitch_org = who_data.map(&:organisation).reject(&:blank?)
        HowField.projects_organisation_no_of_organisations(reporting,program,pitch_org)
      end
    when "Projects"
      case reporting["what_field_2"]
      when "number_of_projects"
        HowField.project_projects_no_of_projects(reporting,program,who_data)
      end
    when "Engagement"
      case reporting["what_field_2"]
      when "Engagement"
        case reporting["what_field_3"]
        when "Time spent on platform"
        when "Average user session length"
        when "Number of likes"
          HowField.projects_engagement_no_of_likes(reporting,program,who_data)
        when "Number of comments"
          HowField.projects_engagement_no_of_comments(reporting,program,who_data)
        when "Number of posts on community feed" 
        when "Number of events signed up to" 
        when "Number of responses to reminders"
        end
      end
    when "Learning"
      case reporting["what_field_2"]
      when "Formal"
        case reporting["what_field_3"]
        when "Number of modules completed"
          HowField.projects_learning_completed_modules(reporting,program,who_data)      
        when "Number of activities completed"
          HowField.projects_learning_completed_activities(reporting,program,who_data)      
       when "Hours of content consumed"
          HowField.projects_learning_hours_consumed(reporting,program,who_data)      
       end
      when "Action"
        case reporting["what_field_3"]
        when "Number of tasks completed"
          HowField.projects_learning_tasks_completed(reporting,program,who_data)
        when "Number of iterations"
          HowField.projects_no_of_iterations(reporting,program,who_data)
        when "Number of times feedback requested"
          HowField.projects_feedback_requested(reporting,program,who_data)
        when "Number of posts on project feed"
          HowField.projects_learning_posts_on_project_feed(reporting,program,who_data)
        end
      when "Social"
        case reporting["what_field_3"]
        when "Number of times feedback received"
          HowField.projects_feedback_requested(reporting,program,who_data)
        when "Number of times feedback given"
          HowField.projects_feedback_requested(reporting,program,who_data)
        end
      end
    when "Quality"
    when "Survey"
    end
  end 

  def self.organisations(reporting,program,who_data)
    case reporting["what_field_1"] 
    when "Participants"
      case reporting["what_field_2"]
      when "number_of_participants"
        participants = User.participants(program.id.to_s)
        all_participants = participants.where(:organisation.in=>who_data.map(&:id))
        return HowField.participants_participants_no_of_participants(reporting,program,all_participants)
      end
    when "Organisations"
    case reporting["what_field_2"]
      when "number_of_organisations"
        HowField.participants_organisation_no_of_organisations(reporting,program,who_data.map(&:id))
      end
    when "Projects"
      case reporting["what_field_2"]
      when "number_of_projects"
        projects = program.pitches.where(:organisation.in=>who_data.map(&:id))
        HowField.project_projects_no_of_projects(reporting,program,projects)
      end
    when "Engagement"
    when "Learning"
      case reporting["what_field_2"]
      when "Formal"
        case reporting["what_field_3"]
        when "Number of modules completed"
          HowField.organisations_learning_completed_modules(reporting,program,who_data)      
        when "Number of activities completed"
          HowField.organisations_learning_completed_activities(reporting,program,who_data)      
        when "Hours of content consumed"
          HowField.organisations_learning_hours_consumed(reporting,program,who_data)      
        end
      when "Action"
        case reporting["what_field_3"]
        when "Number of tasks completed"
          HowField.organisations_learning_tasks_completed(reporting,program,who_data)
        when "Number of iterations"
          HowField.organisations_no_of_iterations(reporting,program,who_data)
        when "Number of times feedback requested"
          HowField.organisations_feedback_requested(reporting,program,who_data)
        when "Number of posts on project feed"
          HowField.organisations_learning_posts_on_project_feed(reporting,program,who_data)
        end
      when "Social"
        case reporting["what_field_3"]
        when "Number of times feedback received"
          HowField.organisations_feedback_requested(reporting,program,who_data)
        when "Number of times feedback given"
          HowField.organisations_feedback_requested(reporting,program,who_data)
        end
      end
    when "Quality"
    when "Survey"
    end
  end 

end