include ActionView::Helpers::DateHelper

class HowField

	def self.participants_participants_no_of_participants(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
        when "particiapant_filter_fields" 
          filters = []
          participant_field_users = []
          custom_fields = User.custom_fields_with_anchor("participant").enabled.for_program(program).filters.to_a
          custom_fields.each do |filter|
            filter.options.each_with_index do |option,index|
              custom_field_options =  {:"custom_fields.#{filter.code}" => option}
              participant_field_users << "#{filter.code}->#{option}"
              participant_field_users <<  User.where(:id.in => what_data.map(&:id)).or(custom_field_options).count
            end
          end
          count = Hash[*participant_field_users]
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Filter Fields"
          chart[2] = "Participants"
          return chart
        when "approval_status"
          approved_participants = what_data.count
          awaited_participants = User.where(:"_awaiting_participant".in => [program.id.to_s]).count
          rejected_participants = User.where(:"_rejected_participant".in => [program.id.to_s]).count
          participants_status = ["Approved Participants", approved_participants,"Awaiting Participants", awaited_participants, "Rejected Participants", rejected_participants]
          count = Hash[*participants_status]
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Approval Status"
          chart[2] = "Participants"
          return chart
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          count = Hash.new(0) 
          participants = what_data.map(&:id)
          pitches = []
          pitches << program.pitches.where(:user_id.in => participants)
          participants.each do |participant|
            pitches << program.pitches.where(:members=>participant.to_s)
          end
          pitches = pitches.flatten
          data = pitches.collect{|p| p.id}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
 	        chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Participants"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
          count = Hash.new(0)
          data = what_data.collect{|p| Organisation.where(:id => p.organisation).try(:first).try(:type)}
          data.collect{|p| (p.blank? ? "No Type" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Type"
          chart[2] = "Participants"
          return chart
        when "industry"
          count = Hash.new(0)
          data = what_data.collect{|p| Organisation.where(:id => p.organisation).try(:first).try(:industry)}
          data.collect{|p| (p.blank? ? "No Industry" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Industry"
          chart[2] = "Participants"
          return chart
        when "size"
          count = Hash.new(0)
          data = what_data.collect{|p| Organisation.where(:id => p.organisation).try(:first).try(:size)}
          data.collect{|p| (p.blank? ? "No Size" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Size"
          chart[2] = "Participants"
          return chart
        end
      end
    end
  end

  def self.participant_projects_no_of_projects(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
      if !reporting["how_field_4"].blank?
        interval=[]
        interval=reporting["how_field_4"].split(",").collect{|p| p.to_i}.uniq.sort
        fixed_interval=interval.collect{|p| ((interval.index(p) < interval.length-1  && interval.index(p)!=0) ? (p==((interval[((interval.index(p)+1))])-1) ? p : (p+1)) : p)}.compact
        total_interval = (interval+fixed_interval).uniq.flatten.sort
        if total_interval.length%2 == 0
          total_interval[total_interval.length]=total_interval[total_interval.length-1]+1
        end
        even_interval = []
        even_interval = (0..total_interval.length-1).collect{|p| p if p.even?}.compact
        correct_interval = even_interval.collect{|p| "#{total_interval[p]}#{!total_interval[p+1].blank? ? -total_interval[p+1] : "+"}"}
        count = Hash.new(0) 
        participant_ids = what_data.map{|p| [p.members,p.user_id.to_s]}.flatten
        data = participant_ids.collect{|v| count[v] += 1}
        data_seprate = Hash.new(0)
        count.values.collect{|v| data_seprate[v] += 1} 
        total = 0
        project_data = correct_interval.collect{|p| [p,( p.split("-").length == 2 ? p.split("-")[0].to_i..p.split("-")[1].to_i : p.split("-")).collect{|q|  (correct_interval.index(p) == correct_interval.length-1) ? data_seprate.map{|k,v| total+=v if k>=q.to_i}.compact.last : data_seprate[q.to_i]}.sum]}
        chart = []
        chart[0] = project_data
        chart[1] = "Projects"
        chart[2] = "Participants"
        return chart
      end
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participant_ids = what_data.map{|p| [p.members,p.user_id.to_s]}.flatten
          count = Hash.new(0)
          data = participant_ids.collect{|v| count[v] += 1}
          count = count.sort_by{|k,v| v}
          chart = []
 	        chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Projects"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"
        when "project_phase"
          phases = []
          workflows = program.workflows
          workflows.each do |workflow|
             if workflow.active?
              phases << workflow.phase_name
              phases << workflow.pitch_phases.where(:pitch_id.in => what_data.map(&:id)).count
            end
          end
          count = Hash[*phases]
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Phases"
          chart[2] = "Projects"
          return chart
        when "project_filter_fields"
          filters = []
          pitch_fields = []
          custom_fields = Pitch.custom_fields_with_anchor("pitch").enabled.for_program(program).filters.to_a
          custom_fields.each do |filter|
            filter.options.each_with_index do |option,index|
              custom_field_options =  {:"custom_fields.#{filter.code}" => option}
              pitch_fields << "#{filter.code}->#{option}"
              pitch_fields << program.pitches.where(:id.in => what_data.map(&:id)).or(custom_field_options).count
            end
          end
          count = Hash[*pitch_fields]
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Custom Filter Fields"
          chart[2] = "Projects"
          return chart
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
          count = Hash.new(0)
          data = what_data.collect{|p| Organisation.where(:id => p.organisation).try(:first).try(:type)}
          data.collect{|p| (p.blank? ? "No Type" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Type"
          chart[2] = "Projects"
          return chart
        when "industry"
          count = Hash.new(0)
          data = what_data.collect{|p| Organisation.where(:id => p.organisation).try(:first).try(:industry)}
          data.collect{|p| (p.blank? ? "No Industry" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Industry"
          chart[2] = "Projects"
          return chart
        when "size"
          count = Hash.new(0)
          data = what_data.collect{|p| Organisation.where(:id => p.organisation).try(:first).try(:size)}
          data.collect{|p| (p.blank? ? "No Size" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Size"
          chart[2] = "Projects"
          return chart
        end
      end
    end
  end

  def self.participants_organisation_no_of_organisations(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants = User.participants(program.id.to_s)
          participants = participants.where(:organisation.in => what_data)
          participant_ids = participants.map(&:id).flatten
          count = Hash.new(0)
          data = participant_ids.collect{|v| count[v] += 1}
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Organisations"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          count = Hash.new(0) 
          pitches = program.pitches.where(:organisation.in => what_data)
          data = pitches.collect{|p| p.id}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Organisations"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
          count = Hash.new(0)
          organisation = Organisation.where(:id.in => what_data)
          data = organisation.collect{|p| p.type}
          data.collect{|p| (p.blank? ? "No Type" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Type"
          chart[2] = "Organisations"
          return chart
        when "industry"
          count = Hash.new(0)
          organisation = Organisation.where(:id.in => what_data)
          data = organisation.collect{|p| p.industry}
          data.collect{|p| (p.blank? ? "No Industry" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Industry"
          chart[2] = "Organisations"
          return chart
        when "size"
          count = Hash.new(0)
          organisation = Organisation.where(:id.in => what_data)
          data = organisation.collect{|p| p.size}
          data.collect{|p| (p.blank? ? "No Size" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Size"
          chart[2] = "Organisations"
          return chart
        end
      end
    end
  end

  def self.participant_engagement_time_spent(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          count = what_data.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Time in days"
          return chart
        when "particiapant_filter_fields" 
        end
      end
    end
  end

  def self.participant_engagement_no_of_likes(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          count = what_data.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Likes"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all" 
        when "project_phase"
        when "project_filter_fields"
        end
      end
    end
  end

  def self.participant_engagement_no_of_comments(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          count = what_data.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Comments"
          return chart
        when "particiapant_filter_fields" 
        end
      end
    end
  end

  def self.participant_engagement_no_of_posts_on_community_feed(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          count = what_data.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Posts"
          return chart
        when "particiapant_filter_fields" 
        end
      end
    end
  end

  def self.participants_learning_completed_activities(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_activities = what_data.collect{|p| ([p.id, p.activity_performances.count] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = participants_activities.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Activities Completed"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          participants = what_data.map(&:id)
          pitches = []
          pitches << program.pitches.where(:user_id.in => participants)
          participants.each do |participant|
            pitches << program.pitches.where(:members=>participant.to_s)
          end
          pitches = pitches.flatten.uniq
          pitches_activities = pitches.collect{|p| ([p.id, p.activity_performances.count] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = pitches_activities.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Activities Completed"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.participants_learning_hours_consumed(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_activities = what_data.collect{|p| ([p.id, self.hours_calulate(p.activity_performances.collect{|p| p.module_activity.time_taken})] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = participants_activities.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Hours consumed"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          participants = what_data.map(&:id)
          pitches = []
          pitches << program.pitches.where(:user_id.in => participants)
          participants.each do |participant|
            pitches << program.pitches.where(:members=>participant.to_s)
          end
          pitches = pitches.flatten.uniq
          pitches_activities = pitches.collect{|p| ([p.id, self.hours_calulate(p.activity_performances.collect{|p| p.module_activity.time_taken})] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = pitches_activities.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Hours consumed"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.participants_learning_completed_modules(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          module_completed = what_data.collect{|p| [p.id,p.activity_performances.map(&:module_activity).map(&:course_module).map(&:id)] if !p.activity_performances.blank?}.compact.collect{|p| [p[0],self.modules_completed(self.count_element_in_array(p[1]))]}
          count = Hash.new(0)
          count = module_completed.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Modules Completed"          
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          participants = what_data.map(&:id)
          pitches = []
          pitches << program.pitches.where(:user_id.in => participants)
          participants.each do |participant|
            pitches << program.pitches.where(:members=>participant.to_s)
          end
          pitches = pitches.flatten.uniq
          module_completed = pitches.collect{|p| [p.id,p.activity_performances.map(&:module_activity).map(&:course_module).map(&:id)] if !p.activity_performances.blank?}.compact.collect{|p| [p[0],self.modules_completed(self.count_element_in_array(p[1]))]}
          count = Hash.new(0)
          count = module_completed.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Modules Completed"          
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.participants_learning_tasks_completed(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          task_completed = what_data.collect{|p| ([p.id, p.activity_performances.map(&:module_activity).map(&:activity_project_fields).count] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = task_completed.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Tasks Completed"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          participants = what_data.map(&:id)
          pitches = []
          pitches << program.pitches.where(:user_id.in => participants)
          participants.each do |participant|
            pitches << program.pitches.where(:members=>participant.to_s)
          end
          pitches = pitches.flatten.uniq
          task_completed = pitches.collect{|p| ([p.id, p.activity_performances.map(&:module_activity).map(&:activity_project_fields).count] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = task_completed.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Tasks Completed"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.participants_feedback_requested(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          feedbacks = what_data.collect{|p| [p.id, PitchFeedback.where(user_id: p.id.to_s).count]}.compact
          count = Hash.new(0)
          count = feedbacks.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Feedbacks"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          participants = what_data.map(&:id)
          pitches = []
          pitches << program.pitches.where(:user_id.in => participants)
          participants.each do |participant|
            pitches << program.pitches.where(:members=>participant.to_s)
          end
          pitches = pitches.flatten.uniq
          feedbacks = pitches.collect{|p| [p.id, p.feedbacks.count]}.compact
          count = Hash.new(0)
          count = feedbacks.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Feedbacks"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.participants_learning_posts_on_project_feed(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants = what_data.map(&:id)
          pitches = []
          pitches << program.pitches.where(:user_id.in => participants)
          participants.each do |participant|
            pitches << program.pitches.where(:members=>participant.to_s)
          end
          pitches = pitches.flatten.uniq
          community_feed_posts = pitches.collect{|p| CommunityFeed.for_pitch(p.id)}.reject(&:blank?).flatten
          participants_posts = what_data.collect{|q| [q.id, community_feed_posts.collect{|p| p.created_by_id.to_s == q.id.to_s}.reject(&:blank?).count]}
          count = participants_posts.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Posts"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          participants = what_data.map(&:id)
          pitches = []
          pitches << program.pitches.where(:user_id.in => participants)
          participants.each do |participant|
            pitches << program.pitches.where(:members=>participant.to_s)
          end
          pitches = pitches.flatten.uniq
          project_posts = pitches.collect{|p| [p.id, CommunityFeed.for_pitch(p.id).count]}.reject(&:blank?)
          count = project_posts.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Posts"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      end
    end
  end

  def self.participants_no_of_iterations(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          participants = what_data.map(&:id)
          pitches = []
          pitches << program.pitches.where(:user_id.in => participants)
          participants.each do |participant|
            pitches << program.pitches.where(:members=>participant.to_s)
          end
          pitches = pitches.flatten.uniq
          project_posts = pitches.collect{|p| [p.id, p.try(:summary).try(:history_tracks).try(:count)]}.reject(&:blank?)
          count = project_posts.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Iterations"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      end
    end
  end

  def self.project_participants_no_of_participants(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
      if !reporting["how_field_4"].blank?
        interval=[]
        interval=reporting["how_field_4"].split(",").collect{|p| p.to_i}.uniq.sort
        fixed_interval=interval.collect{|p| ((interval.index(p) < interval.length-1  && interval.index(p)!=0) ? (p==((interval[((interval.index(p)+1))])-1) ? p : (p+1)) : p)}.compact
        total_interval = (interval+fixed_interval).uniq.flatten.sort
        if total_interval.length%2 == 0
          total_interval[total_interval.length]=total_interval[total_interval.length-1]+1
        end
        even_interval = []
        even_interval = (0..total_interval.length-1).collect{|p| p if p.even?}.compact
        correct_interval = even_interval.collect{|p| "#{total_interval[p]}#{!total_interval[p+1].blank? ? -total_interval[p+1] : "+"}"}
        count = Hash.new(0) 
        participants_ids = what_data.map(&:id)
        pitches = []
        pitches << program.pitches.where(:user_id.in => participants_ids)
        participants_ids.each do |participant|
          pitches << program.pitches.where(:members=>participant.to_s)
        end
        pitches = pitches.flatten
        data = pitches.collect{|p| p.id}.collect{|v| count[v] += 1} 
        data_seprate = Hash.new(0)
        count.values.collect{|v| data_seprate[v] += 1} 
        total = 0
        project_data = correct_interval.collect{|p| [p,( p.split("-").length == 2 ? p.split("-")[0].to_i..p.split("-")[1].to_i : p.split("-")).collect{|q|  (correct_interval.index(p) == correct_interval.length-1) ? data_seprate.map{|k,v| total+=v if k>=q.to_i}.compact.last : data_seprate[q.to_i]}.sum]}
        chart = []
        chart[0] = project_data
        chart[1] = "Participants"
        chart[2] = "Projects"
        return chart
      end
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
        when "particiapant_filter_fields" 
          filters = []
          participant_field_users = []
          custom_fields = User.custom_fields_with_anchor("participant").enabled.for_program(program).filters.to_a
          custom_fields.each do |filter|
            filter.options.each_with_index do |option,index|
              custom_field_options =  {:"custom_fields.#{filter.code}" => option}
              participant_field_users << "#{filter.code}->#{option}"
              participant_field_users <<  User.where(:id.in => what_data.map(&:id)).or(custom_field_options).count
            end
          end
          count = Hash[*participant_field_users]
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Filter Fields"
          chart[2] = "Participants"
          return chart
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all" 
          count = Hash.new(0) 
          participants_ids = what_data.map(&:id)
          pitches = []
          pitches << program.pitches.where(:user_id.in => participants_ids)
          participants_ids.each do |participant|
            pitches << program.pitches.where(:members=>participant.to_s)
          end
          pitches = pitches.flatten
          data = pitches.collect{|p| p.id}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
 	        chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Participants"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
          count = Hash.new(0)
          data = what_data.collect{|p| Organisation.where(:id => p.organisation).try(:first).try(:type)}
          data.collect{|p| (p.blank? ? "No Type" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Type"
          chart[2] = "Participants"
          return chart
        when "industry"
          count = Hash.new(0)
          data = what_data.collect{|p| Organisation.where(:id => p.organisation).try(:first).try(:industry)}
          data.collect{|p| (p.blank? ? "No Industry" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Industry"
          chart[2] = "Participants"
          return chart
        when "size"
          count = Hash.new(0)
          data = what_data.collect{|p| Organisation.where(:id => p.organisation).try(:first).try(:size)}
          data.collect{|p| (p.blank? ? "No Size" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Size"
          chart[2] = "Participants"
          return chart
        end
      end
    end
  end

  def self.project_projects_no_of_projects(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_ids = what_data.map{|p| [p.members,p.user_id.to_s]}.flatten
          count = Hash.new(0)
          data = participants_ids.collect{|v| count[v] += 1}
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Projects"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
        when "project_phase"
          phases = []
          workflows = program.workflows
          workflows.each do |workflow|
             if workflow.active?
              phases << workflow.phase_name
              phases << workflow.pitch_phases.where(:pitch_id.in => what_data.map(&:id)).count
            end
          end
          count = Hash[*phases]
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Phases"
          chart[2] = "Projects"
          return chart
        when "project_filter_fields"
          filters = []
          pitch_fields = []
          custom_fields = Pitch.custom_fields_with_anchor("pitch").enabled.for_program(program).filters.to_a
          custom_fields.each do |filter|
            filter.options.each_with_index do |option,index|
              custom_field_options =  {:"custom_fields.#{filter.code}" => option}
              pitch_fields << "#{filter.code}->#{option}"
              pitch_fields << program.pitches.where(:id.in => what_data.map(&:id)).or(custom_field_options).count
            end
          end
          count = Hash[*pitch_fields]
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Custom Filter Fields"
          chart[2] = "Projects"
          return chart
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
          count = Hash.new(0)
          data = what_data.collect{|p| Organisation.where(:id => p.organisation).try(:first).try(:type)}
          data.collect{|p| (p.blank? ? "No Type" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Type"
          chart[2] = "Projects"
          return chart
        when "industry"
          count = Hash.new(0)
          data = what_data.collect{|p| Organisation.where(:id => p.organisation).try(:first).try(:industry)}
          data.collect{|p| (p.blank? ? "No Industry" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Industry"
          chart[2] = "Projects"
          return chart
        when "size"
          count = Hash.new(0)
          data = what_data.collect{|p| Organisation.where(:id => p.organisation).try(:first).try(:size)}
          data.collect{|p| (p.blank? ? "No Size" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Size"
          chart[2] = "Projects"
          return chart
        end
      end
    end
  end

  def self.projects_organisation_no_of_organisations(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants = User.participants(program.id.to_s)
          participants = participants.where(:organisation.in => what_data)
          participant_ids = participants.map(&:id).flatten
          count = Hash.new(0)
          data = participant_ids.collect{|v| count[v] += 1}
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Organisations"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          count = Hash.new(0) 
          pitches = program.pitches.where(:organisation.in => what_data)
          data = pitches.collect{|p| p.id}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Organisations"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
          count = Hash.new(0)
          organisation = Organisation.where(:id.in => what_data)
          data = organisation.collect{|p| p.type}
          data.collect{|p| (p.blank? ? "No Type" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Type"
          chart[2] = "Organisations"
          return chart
        when "industry"
          count = Hash.new(0)
          organisation = Organisation.where(:id.in => what_data)
          data = organisation.collect{|p| p.industry}
          data.collect{|p| (p.blank? ? "No Industry" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Industry"
          chart[2] = "Organisations"
          return chart
        when "size"
          count = Hash.new(0)
          organisation = Organisation.where(:id.in => what_data)
          data = organisation.collect{|p| p.size}
          data.collect{|p| (p.blank? ? "No Size" : p)}.collect{|v| count[v] += 1} 
          count = count.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{p[0]}",p[1]]}
          chart[1] = "Organisation Size"
          chart[2] = "Organisations"
          return chart
        end
      end
    end
  end

  def self.projects_engagement_no_of_likes(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          pitch_feeds = what_data.collect{|p| CommunityFeed.feed_for_pitch(program.id, p)}.flatten.reject(&:blank?)
          post_and_comments = pitch_feeds.collect{|p| [p,p.comments]}.reject(&:blank?).flatten
          participants_ids = what_data.map{|p| [p.members,p.user_id.to_s]}.flatten.uniq
          participants_likes = participants_ids.collect{|q| [q, post_and_comments.collect{|p| p.liked_by?(User.where(:id=>q.to_s).try(:first))}.reject(&:blank?).count]}
          count = participants_likes.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Likes"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all" 
          pitch_likes = what_data.collect{|p| [p.id,CommunityFeed.feed_for_pitch(program.id, p).where(:likes_count.ne => 0).count]}
          count = pitch_likes.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Likes"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      end
    end
  end

  def self.projects_engagement_no_of_comments(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          pitch_feeds = what_data.collect{|p| CommunityFeed.feed_for_pitch(program.id, p)}.flatten.reject(&:blank?)
          all_comments = pitch_feeds.collect{|p| [p.comments,p.comments.collect{|p| p.children}]}.reject(&:blank?).flatten
          participants_ids = what_data.map{|p| [p.members,p.user_id.to_s]}.flatten.uniq
          participants_comments = participants_ids.collect{|q| [q, all_comments.collect{|p| p.commented_by_id.to_s == q.to_s}.reject(&:blank?).count]}
          count = participants_comments.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Comments"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all" 
          pitch_comments  = what_data.collect{|p| [p.id,CommunityFeed.feed_for_pitch(program.id, p).collect{|p| [p.comments, p.comments.collect{|q| q.children}]}.flatten.reject(&:blank?).count]}
          count = pitch_comments.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Comments"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      end
    end
  end

  def self.projects_learning_completed_activities(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_ids = what_data.map{|p| [p.members,p.user_id.to_s]}.flatten
          participants = User.where(:id.in => participants_ids).flatten
          participants_activities = participants.collect{|p| ([p.id, p.activity_performances.count] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = participants_activities.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Activities Completed"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          pitches_activities = what_data.collect{|p| ([p.id, p.activity_performances.count] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = pitches_activities.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Activities Completed"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.projects_learning_hours_consumed(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_ids = what_data.map{|p| [p.members,p.user_id.to_s]}.flatten
          participants = User.where(:id.in => participants_ids).flatten
          participants_activities = participants.collect{|p| ([p.id, self.hours_calulate(p.activity_performances.collect{|p| p.module_activity.time_taken})] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = participants_activities.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Hours consumed"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          pitches_activities = what_data.collect{|p| ([p.id, self.hours_calulate(p.activity_performances.collect{|p| p.module_activity.time_taken})] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = pitches_activities.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Hours consumed"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.projects_learning_completed_modules(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_ids = what_data.map{|p| [p.members,p.user_id.to_s]}.flatten
          participants = User.where(:id.in => participants_ids).flatten
          module_completed = participants.collect{|p| [p.id,p.activity_performances.map(&:module_activity).map(&:course_module).map(&:id)] if !p.activity_performances.blank?}.compact.collect{|p| [p[0],self.modules_completed(self.count_element_in_array(p[1]))]}
          count = Hash.new(0)
          count = module_completed.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Modules Completed"          
          return chart         
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          module_completed = what_data.collect{|p| [p.id,p.activity_performances.map(&:module_activity).map(&:course_module).map(&:id)] if !p.activity_performances.blank?}.compact.collect{|p| [p[0],self.modules_completed(self.count_element_in_array(p[1]))]}
          count = Hash.new(0)
          count = module_completed.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Modules Completed"          
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.projects_learning_tasks_completed(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_ids = what_data.map{|p| [p.members,p.user_id.to_s]}.flatten
          participants = User.where(:id.in => participants_ids).flatten
          task_completed = participants.collect{|p| ([p.id, p.activity_performances.map(&:module_activity).map(&:activity_project_fields).count] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = task_completed.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Tasks Completed"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          task_completed = what_data.collect{|p| ([p.id, p.activity_performances.map(&:module_activity).map(&:activity_project_fields).count] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = task_completed.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Tasks Completed"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.projects_feedback_requested(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_ids = what_data.map{|p| [p.members,p.user_id.to_s]}.flatten
          participants = User.where(:id.in => participants_ids).flatten
          feedbacks = participants.collect{|p| [p.id,PitchFeedback.where(user_id: p.id.to_s).count]}.compact
          count = Hash.new(0)
          count = feedbacks.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Feedbacks"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          feedbacks = what_data.collect{|p| [p.id, p.feedbacks.count]}.compact
          count = Hash.new(0)
          count = feedbacks.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Feedbacks"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.projects_learning_posts_on_project_feed(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_ids = what_data.map{|p| [p.members,p.user_id.to_s]}.flatten
          participants = User.where(:id.in => participants_ids).flatten
          community_feed_posts = what_data.collect{|p| CommunityFeed.for_pitch(p.id)}.reject(&:blank?).flatten
          participants_posts = participants.collect{|q| [q.id, community_feed_posts.collect{|p| p.created_by_id.to_s == q.id.to_s}.reject(&:blank?).count]}
          count = participants_posts.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Posts"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          project_posts = what_data.collect{|p| [p.id, CommunityFeed.for_pitch(p.id).count]}.reject(&:blank?)
          count = project_posts.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Posts"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      end
    end
  end

  def self.projects_no_of_iterations(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"
          project_posts = what_data.collect{|p| [p.id, p.try(:summary).try(:history_tracks).try(:count)]}.reject(&:blank?)
          count = project_posts.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Iterations"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      end
    end
  end

  def self.organisations_learning_completed_activities(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_fetch = User.participants(program.id.to_s)
          participants = participants_fetch.where(:organisation.in=>what_data.map(&:id))
          participants_activities = participants.collect{|p| ([p.id, p.activity_performances.count] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = participants_activities.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Activities Completed"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          pitches = program.pitches.where(:organisation.in=>what_data.map(&:id))
          pitches_activities = pitches.collect{|p| ([p.id, p.activity_performances.count] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = pitches_activities.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Activities Completed"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.organisations_learning_hours_consumed(reporting,program,what_data)
   case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_fetch = User.participants(program.id.to_s)
          participants = participants_fetch.where(:organisation.in=>what_data.map(&:id))
          participants_activities = participants.collect{|p| ([p.id, p.activity_performances.count] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = participants_activities.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Hours consumed"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          pitches = program.pitches.where(:organisation.in=>what_data.map(&:id))
          pitches_activities = pitches.collect{|p| ([p.id, self.hours_calulate(p.activity_performances.collect{|p| p.module_activity.time_taken})] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = pitches_activities.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Hours consumed"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end
  
  def self.organisations_learning_completed_modules(reporting,program,what_data)
   case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_fetch = User.participants(program.id.to_s)
          participants = participants_fetch.where(:organisation.in=>what_data.map(&:id))
          module_completed = participants.collect{|p| [p.id,p.activity_performances.map(&:module_activity).map(&:course_module).map(&:id)] if !p.activity_performances.blank?}.compact.collect{|p| [p[0],self.modules_completed(self.count_element_in_array(p[1]))]}
          count = Hash.new(0)
          count = module_completed.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Modules Completed"  
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          pitches = program.pitches.where(:organisation.in=>what_data.map(&:id))
          module_completed = pitches.collect{|p| [p.id,p.activity_performances.map(&:module_activity).map(&:course_module).map(&:id)] if !p.activity_performances.blank?}.compact.collect{|p| [p[0],self.modules_completed(self.count_element_in_array(p[1]))]}
          count = Hash.new(0)
          count = module_completed.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Modules Completed"  
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.organisations_learning_tasks_completed(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_fetch = User.participants(program.id.to_s)
          participants = participants_fetch.where(:organisation.in=>what_data.map(&:id))
          task_completed = participants.collect{|p| ([p.id, p.activity_performances.map(&:module_activity).map(&:activity_project_fields).count] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = task_completed.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Activities Completed"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          pitches = program.pitches.where(:organisation.in=>what_data.map(&:id))
          task_completed = pitches.collect{|p| ([p.id, p.activity_performances.map(&:module_activity).map(&:activity_project_fields).count] if !p.activity_performances.blank?)}.compact
          count = Hash.new(0)
          count = task_completed.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Activities Completed"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.organisations_feedback_requested(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_fetch = User.participants(program.id.to_s)
          participants = participants_fetch.where(:organisation.in=>what_data.map(&:id))
          feedbacks = participants.collect{|p| [p.id, PitchFeedback.where(user_id: p.id.to_s).count]}.compact
          count = feedbacks.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Feedbacks"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          pitches = program.pitches.where(:organisation.in=>what_data.map(&:id))
          feedbacks = pitches.collect{|p| [p.id, p.feedbacks.count]}.compact
          count = feedbacks.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Feedbacks"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      when "filter_organisations"
        case reporting["how_field_3"]
        when "organisation_type" 
        when "industry"
        when "size"
        end
      end
    end
  end

  def self.organisations_learning_posts_on_project_feed(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_participants"
        case reporting["how_field_3"]
        when "particiapant_all"
          participants_fetch = User.participants(program.id.to_s)
          participants = participants_fetch.where(:organisation.in=>what_data.map(&:id))
          pitches = program.pitches.where(:organisation.in=>what_data.map(&:id))
          community_feed_posts = pitches.collect{|p| CommunityFeed.for_pitch(p.id)}.reject(&:blank?).flatten
          participants_posts = participants.collect{|q| [q.id, community_feed_posts.collect{|p| p.created_by_id.to_s == q.id.to_s}.reject(&:blank?).count]}
          count = participants_posts.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{User.where(:id => p[0].to_s).try(:first).try(:full_name)}",p[1]]}
          chart[1] = "Participants"
          chart[2] = "Posts"
          return chart
        when "particiapant_filter_fields" 
        end
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"  
          pitches = program.pitches.where(:organisation.in=>what_data.map(&:id))
          project_posts = pitches.collect{|p| [p.id, CommunityFeed.for_pitch(p.id).count]}.reject(&:blank?)
          count = project_posts.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Posts"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      end
    end
  end

  def self.organisations_no_of_iterations(reporting,program,what_data)
    case reporting["how_field_1"] 
    when "Interval"
    when "FilteredBy"
      case reporting["how_field_2"]
      when "filter_projects"
        case reporting["how_field_3"]
        when "project_all"
          pitches = program.pitches.where(:organisation.in=>what_data.map(&:id))
          project_posts = pitches.collect{|p| [p.id, p.try(:summary).try(:history_tracks).try(:count)]}.reject(&:blank?)
          count = project_posts.sort_by{|k,v| v}
          chart = []
          chart[0] = count.map{|p| ["#{count.index(p)+1}. #{Pitch.where(:id => p[0].to_s).try(:first).try(:title)}",p[1]]}
          chart[1] = "Projects"
          chart[2] = "Iterations"
          return chart
        when "project_phase"
        when "project_filter_fields"
        end
      end
    end
  end

  def self.hours_calulate(hours)
    time_taken = 0
    hours.each do |d|
      timings = d.split(":")
      time_taken += timings[0].to_i.hour
      time_taken += timings[1].to_i.minutes
    end
    minutes = (time_taken / 60) % 60
    hours = time_taken / (60 * 60)
    if !hours.blank?
      return self.time_cal(hours,minutes)
    else
      return ""
    end
  end

  def self.time_cal(hours,minutes)
    duration =0
    if (hours!=" 0") && (hours!=0) && (hours!="00")
      duration = hours
    end
  end

  def self.count_element_in_array(array_values)
    count = Hash.new(0)
    array_values.map{|p| count[p] += 1}
    return count
  end

  def self.modules_completed(module_ids)
    module_ids.map{|p| CourseModule.where(:id => p[0]).try(:first).try(:module_activities).try(:count) <= p[1]}.reject(&:blank?).count
  end

end
