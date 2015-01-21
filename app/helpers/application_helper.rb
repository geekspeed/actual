module ApplicationHelper

  def get_program_title(value)
    html_safe_values = {
      "Incubator" => "Incubator<br />&nbsp;  ", 
      "Accelerator + Application Filtering" => "Accelerator  + <br />Application Filtering  ", 
      "Accelerator phase only" => "Accelerator<br />phase only  ", 
      "Competition/Challange" => "Competition /<br />Challenge  ", 
      "Mentoring Program" => "Mentoring<br />program  ", 
      "Collaborative Innovation Program" => "Collaborative Innovation<br />Program  "
    }
    html_safe_values[value].html_safe
  end

  def selected_program
    context_program.present? ? (current_user.role?("awaiting_participant", context_program) or 
    current_user.role?("awaiting_mentor", context_program)) ? "Select Program" : (current_user.role?("ecosystem_member", current_organisation) ? (context_program.master_program ? "Select Program" : context_program.title) : context_program.title) : "Select Program"
  end

  def navbar_pitch_link(pitch_selected = nil)
    is_subdomain = valid_subdomain(current_subdomain)

    if context_program.present?
      pitches = context_program.pitches.or(:user_id => current_user.id.to_s).
                or(:members => current_user.id.to_s)
      mentor_pitches = context_program.pitches.in(:mentors => current_user.id.to_s)
      if pitches.present? or mentor_pitches.present?
          res = []
          if pitches.present?
            res << pitches.collect{ |pitch|
              pitch_main_url = (context_program.try(:course_setting).try(:user_section) == "course_show" && !context_program.course.blank? && context_program.courses_part_of_program) ? (is_subdomain ? polymorphic_url([context_program, pitch, context_program.course, :show], subdomain: false) : polymorphic_url([context_program, pitch, context_program.course, :show])) : (is_subdomain ? edit_program_pitch_path(context_program, pitch, subdomain: false) : edit_program_pitch_path(context_program, pitch))
              content_tag(:li, link_to(pitch.title, pitch_main_url), :class => pitch_selected == pitch ? "active": "")
            }
          end
          if mentor_pitches.present?
            res << mentor_pitches.collect{ |pitch|
              pitch_main_url = (context_program.try(:course_setting).try(:user_section) == "course_show" && !context_program.course.blank? && context_program.courses_part_of_program) ? (is_subdomain ? polymorphic_url([context_program, pitch, context_program.course, :show], subdomain: false) : polymorphic_url([context_program, pitch, context_program.course, :show])) : (is_subdomain ? edit_program_pitch_path(context_program, pitch, subdomain: false) : edit_program_pitch_path(context_program, pitch))
              content_tag(:li, link_to(pitch.title, pitch_main_url), :class => pitch_selected == pitch ? "active": "")
            }
          end
          if context_program.program_scope.try(:multiple_pitches) and !context_program.workflows.where(:code => "submission_deadline").first.try(:active) and (need?(["participant"], context_program) and !context_program.try(:program_scope).try(:stop_adding_project_participants))
            res << content_tag(:li, link_to("+ Add #{t("pitch", "s")}", (is_subdomain ? new_program_pitch_path(context_program, subdomain: false) : new_program_pitch_path(context_program))))
          end
          res.join().html_safe
      else
        content_tag(:li, link_to("+ Add #{t("pitch", "s")}", (is_subdomain ? new_program_pitch_path(context_program, subdomain: false) : new_program_pitch_path(context_program))))
      end
    end
  end

  def mentor_pitches
    is_subdomain = valid_subdomain(current_subdomain)
    if context_program.present?
      pitches = context_program.pitches.in(:mentors => current_user.id.to_s)
      if pitches.present?
        res = pitches.collect{ |pitch|
          content_tag(:li, link_to(pitch.title, (is_subdomain ? edit_program_pitch_path(context_program, pitch, subdomain: false) :  edit_program_pitch_path(context_program, pitch))))
        }
        res.join().html_safe
      end
    end
  end

  def build_new_or_edit_path(hierarchy, object)
    object.persisted? ? edit_polymorphic_path(hierarchy) : new_polymorphic_path(hierarchy)
  end

  def time_in_words(date_or_time)
    compare = date_or_time.is_a?(Date) ? Date.today : Time.now
    sentance = time_ago_in_words(date_or_time)
    if date_or_time < compare
      "#{sentance} ago"
    else
      "#{sentance} ahead"
    end
  end

  def name_or_email(user)
    
    user.full_name.present? ? user.full_name : user.email
  end

  def feed_like_link(feed)
    if feed.liked_by?(current_user)
      if feed.program_id.present?
        link_to("<i class=\"glyphicon glyphicon-heart user_defined_color\"></i> UnLike".html_safe, polymorphic_path([:unlike, feed.program, feed]), :method => :put, :class=> "unlikeFeed user_defined_color", :remote => true)
      else
        link_to("<i class=\"glyphicon glyphicon-heart user_defined_color\"></i> UnLike".html_safe, polymorphic_path([:unlike, feed.organisation, feed]), :method => :put, :class=> "unlikeFeed user_defined_color", :remote => true)
      end
    else
      if feed.program_id.present?
        link_to("<i class=\"glyphicon glyphicon-heart-empty user_defined_color\"></i> Like".html_safe, polymorphic_path([:like, feed.program, feed]), :method => :put, :class=> "likeFeed user_defined_color", :remote => true)
      else
        link_to("<i class=\"glyphicon glyphicon-heart-empty user_defined_color\"></i> Like".html_safe, polymorphic_path([:like, feed.organisation, feed]), :method => :put, :class=> "likeFeed user_defined_color", :remote => true)
      end
    end
  end

  def profile_feed_like_link(feed)
      if feed.program_id.present?
        link_to("<i class=\"glyphicon glyphicon glyphicon-heart-empty\"></i> UnLike".html_safe, polymorphic_path([:unlike, feed.program, feed]), :method => :put, :class=> "unlikeFeed", :remote => true)
      else
        link_to("<i class=\"glyphicon glyphicon glyphicon-heart-empty\"></i> UnLike".html_safe, polymorphic_path([:unlike, feed.organisation, feed]), :method => :put, :class=> "unlikeFeed", :remote => true)
      end
    else
      if feed.program_id.present?
        link_to("<i class=\"glyphicon glyphicon glyphicon-heart-empty\"></i> Like ".html_safe, polymorphic_path([:like, feed.program, feed]), :method => :put, :class=> "likeFeed", :remote => true)
      else
        link_to("<i class=\"glyphicon glyphicon glyphicon-heart-empty\"></i> Like".html_safe, polymorphic_path([:like, feed.organisation, feed]), :method => :put, :class=> "likeFeed", :remote => true)
      end
  end

  def feature_link(feed)
    if feed.featured?
      link_to("Unfeature", polymorphic_path([:unfeature, feed.program, feed]), :method => :put, :class=> "unfeaturefeed", :style=>"margin-top: 5px;")
    else
      link_to("Feature", polymorphic_path([:feature, feed.program, feed]), :method => :put, :class=> "featurefeed", :style=>"margin-top: 5px;")
    end
  end

  def comment_like_link(comment)
    if comment.liked_by?(current_user)
      link_to("<i class=\"glyphicon glyphicon-heart user_defined_color\"></i> UnLike".html_safe, polymorphic_path([:unlike, comment]), :method => :put, :class=> "unlikeFeed user_defined_color")
    else
      link_to("<i class=\"glyphicon glyphicon-heart-empty user_defined_color\"></i> Like".html_safe, polymorphic_path([:like, comment]), :method => :put, :class=> "likeFeed user_defined_color")
    end
  end

  def translate(key, verb = "singular")
    Semantic.translate(context_program, key, verb)
  end
  alias_method :t, :translate

  def eco_translate(key, verb = "singular")
    Semantic.eco_translate((current_organisation || @organisation), key, verb)
  end
  alias_method :e, :eco_translate

  def translate_for_front_pages(key, program=context_program, verb = "singular")
    Semantic.translate_for_front_pages(program, key, verb)
  end
  alias_method :tfp, :translate_for_front_pages

  def company_registration?
    return false if params[:invitation_token].present?
    return false if params[:references] && params[:references][:role_code].present?
    !(!!@user && RoleType.on_programs.collect(&:code).
      any?{|c| @user["_#{c}"].present?})
  end

  def phase_action_allowed?(applicable_role, pitch = nil)
    if ["participant", "mentor"].include?(applicable_role)
      pitch.team_and_mentor_both?(current_user) ? true : (need?([applicable_role], context_program) && pitch.team_and_mentor?(current_user))
    else
      need?([applicable_role], context_program) ||
       need?([applicable_role], current_organisation)
    end
  end

  def submit_deadline?(pitch)
    if pitch.workflows.on.where(code: "submission_deadline").try(:first)
      return (pitch.stop_editing and pitch.workflows.on.where(code: "submission_deadline").try(:first).try(:active?))
    else
      return false
    end
  end

  def active_phase_of_pitch?(pitch, code)
    if pitch.workflows.on.where(code: code).try(:first)
      return pitch.workflows.on.where(code: code).try(:first).try(:active?)
    else
      return false
    end
  end

  def team_or_admin?(pitch = nil)
    return true if current_user.company_admin?(current_organisation)
    need?(["participant", "mentor"], context_program) &&
       pitch.team_and_mentor?(current_user)
  end

  def data_linked(cf, klass)
    if cf.linked.present?
      klass.values_for_linked(cf.linked, cf.code).to_json
    else
      {}.to_json
    end
  end

  def get_custom_field_anchor(force_user = nil)
    if user_signed_in?
      user = force_user || current_user
      if !!context_program
        if user.participant?(context_program)
          return "participant"
        elsif user.mentor?(context_program)
          return "mentor"
        end
      end
    else
      if params[:references]
        if ["participant", "mentor"].include? params[:references][:role_code]
          return params[:references][:role_code]
        elsif ["panellist", "selector"].include?(params[:references][:role_code])
          return "mentor"
        end
      end
    end
  end

  def get_program
    if user_signed_in?
      return context_program
    else
      if params[:references].present?
        return params[:references][:for]
      elsif params[:program_id].present?
        params[:program_id]
      end
    end
  end

  def active_role?(code)
    if context_program and !context_program.mentor_allowed? && code == "mentor"
      false
    elsif context_program and !context_program.penallist_allowed? && code == "panellist"
      false
    elsif context_program and !context_program.selectors_allowed? && code == "selector"
      false
    else
      true
    end
  end

  def sidebar(partial = nil, locals = {})
    if !!partial
      content_for :sidebar do
        render partial, locals: locals
      end
    end
  end

  def mark_required(object, attribute)  
    "*" if object.class.validators_on(attribute).map(&:class).include? ActiveModel::Validations::PresenceValidator  
  end

  def show_help_icon(program, ankor, field, custom_field="")
    if program
      help = program.help_contents.for_custom_field(custom_field).where(text_for: ankor, field_name: field)
      help.empty? ? false : true
    else
      false
    end
  end

  def getting_organisation(org_id)
    Organisation.where(id: org_id).first
  end

  def invitation_link(invitation)
    if invitation.invitee_type == "collaborator"
      return contacts_program_pitch_url(invitation.program, invitation.pitch)
    else
      return polymorphic_url([invitation.program, invitation.pitch])
    end
  end

  def invitation_accept_link(invitation)
    if invitation.invitee_type == "collaborator"
      return add_collaborater_requester_program_pitch_url(invitation.program, invitation.pitch, :user_id => invitation.invited_by_id)
    else
      return accept_invitation_program_pitch_pitch_invitation_url(invitation.program, invitation.pitch, invitation, from_profile: "true")
    end
  end

  def invitation_decline_link(invitation)
    if invitation.invitee_type == "collaborator"
      return remove_collaborater_requester_program_pitch_path(invitation.program, invitation.pitch, :user_id => invitation.invited_by_id)
    else
      return decline_invitation_program_pitch_pitch_invitation_url(invitation.program, invitation.pitch, invitation, from_profile: "true")
    end
  end

  def collaboration_msg invitation
    invitation.pitch.collaborater_requests.where(user_id: invitation.invited_by_id).first.try(:request_text).nil?  ? "" : (raw("<br>" + invitation.pitch.collaborater_requests.where(user_id: invitation.invited_by_id).first.try(:request_text).gsub("\r\n","<br>")))
  end

  def welcome_message(program, roles)
    if roles.include?("participant")
      return program.try(:program_summary).try(:summary_welcome_message).try(:message_for_applicant).try(:html_safe)
    elsif roles.include?("mentor")
      return program.try(:program_summary).try(:summary_welcome_message).try(:message_for_mentor).try(:html_safe)
    elsif roles.include?("selector")
      return program.try(:program_summary).try(:summary_welcome_message).try(:message_for_selector).try(:html_safe)
    elsif roles.include?("panellist")
      return program.try(:program_summary).try(:summary_welcome_message).try(:message_for_panellist).try(:html_safe)
    else
      ""
    end
    
  end

def terms_and_conditions_message(program, roles)
    if roles.include?("participant")
      return program.try(:program_summary).try(:summary_terms_message).try(:message_for_applicant).try(:html_safe)
    elsif roles.include?("mentor")
      return program.try(:program_summary).try(:summary_terms_message).try(:message_for_mentor).try(:html_safe)
    elsif roles.include?("selector")
      return program.try(:program_summary).try(:summary_terms_message).try(:message_for_selector).try(:html_safe)
    elsif roles.include?("panellist")
      return program.try(:program_summary).try(:summary_terms_message).try(:message_for_panellist).try(:html_safe)
    elsif roles.include?("awaiting_participant")
      return program.try(:program_summary).try(:summary_terms_message).try(:message_for_applicant).try(:html_safe)
    elsif roles.include?("awaiting_mentor")
      return program.try(:program_summary).try(:summary_terms_message).try(:message_for_mentor).try(:html_safe)
    else
      ""
    end
    
  end

  def valid_subdomain(subdomain)
    if current_subdomain
      tld1 = current_subdomain.split('.')[0]
      Program.where(id: tld1).first ? true : false
    else
      false
    end
  end

  def accepted_upload_type(custom_field)
    custom_field.try(:options).blank? ? ["All"] : custom_field.try(:options)
  end

  def task_completed?(task)
    if task.task_type == "system_task"
      task.completed_tasks.map(&:user_id).include? current_user.id
    else
     task.complete
    end
  end
  
  def hex_to_rgb(bg_color, opacity, overlay_pattern = true )
    if bg_color
       a = ( bg_color.match /(..?)(..?)(..?)/ )[1..3]
       return "rgba(#{a[0].hex},#{a[1].hex},#{a[2].hex},#{(opacity.to_f/100)})"
     else
       return "background-color:rgba(0,0,0,0.6)"
   end
  end

  def awaited_user   
    if !context_program.present?
      field = (current_user ? ((current_user.try(:attributes).try(:keys) & ["_awaiting_participant", "_awaiting_mentor"]).first) : nil) 
      prog = field.present? ? Program.where(id: current_user.try(field).try(:first)).first : nil
    end
  end   

  def get_domain_branding(domain)
    domain_info = mapped_url(domain)
    if domain_info.try(:program_id).present?
      Program.where(id: domain_info.program_id).first
    elsif domain_info.try(:organisation_id).present?
      Organisation.where(id: domain_info.organisation_id).first.try(:programs).try(:first)
    else
      nil
    end
  end
  
  def human_boolean(boolean)
      boolean ? 'Yes' : 'No'
  end

  def show_help_ques_icon(program,custom_field_id)
    if program
      help_content = program.help_contents.where(field_name: custom_field_id)
      help_content.empty? ? false : true
    else
      false
    end
  end

  def can_create_pitch(ankor)
    if context_program
      !context_program.try(:workflows).where(phase_name: "Submission deadline").first.try(:active) and( (ankor == "mentor" and context_program.try(:can_mentors_post_pitch)) or (ankor == "participant" and context_program.try(:program_scope).try(:multiple_pitches) and !context_program.try(:program_scope).try(:stop_adding_project_participants)))
    end
  end

  def count_users(role, program_id)
    case role
    when "applicant"
     count = User.in("_participant" => program_id.to_s).count
    when "mentor"
     count = User.in("_mentor" => program_id.to_s).count
    when "selector"
     count = User.in("_selector" => program_id.to_s).count
    when "panellist"
     count = User.in("_panellist" => program_id.to_s).count
    end
    count
  end

  def count_invites(role, program_id)
    case role
    when "applicant"
     count = User.in("_invited_participant" => program_id.to_s).count
    when "mentor"
     count = User.in("_invited_mentor" => program_id.to_s).count
    when "panellist"
     count = User.in("_invited_panellist" => program_id.to_s).count
    when "selector"
     count = User.in("_invited_selector" => program_id.to_s).count
    end
    count
  end

  def count_rejected(role, program_id)
    case role
    when "applicant"
     count = User.in("_rejected_participant" => program_id.to_s).count
    when "mentor"
     count = User.in("_rejected_mentor" => program_id.to_s).count
    end
    count
  end
  
  def last_feed(pitch, roles_string)
    CommunityFeed.in(program_id: pitch.program_id, pitch_id: pitch.id.to_s, :post_to.in => roles_string).first
  end
  
  def last_mentor_feed(pitch, roles_string)
    CommunityFeed.in(program_id: pitch.program_id, pitch_id: pitch.id.to_s, :post_to.in => roles_string).or.in(created_by: pitch.mentors).or.in(created_by: pitch.program.organisation.admins).first
  end

  def find_active_phase_of_pitch?(pitch)
    User.find_active_phase_of_pitch?(pitch)
  end

  def pitch_feed_count(pitch, roles_string)
    User.pitch_feed_count(pitch, roles_string)
  end
  
  def workflow_pitch_count(program, phase)
    program.workflows.on.where(:phase_name => phase).first.pitch_phases.map(&:pitch_id).uniq.count
  end

  def count_team(pitch)
    User.count_team(pitch)
  end

  def fetch_mentors(mentors, program)
    pending_mentors, approved_mentors = [],[]
    mentors.each do |user|
      if user.invited_for?(:mentor, program)
        pending_mentors << user
      else
        approved_mentors << user
      end
    end
    return pending_mentors.flatten, approved_mentors.flatten
  end

  def fetch_panellist(panellists, program)
    pending_panellist, approved_panellist = [],[]
    panellists.each do |user|
      if user.invited_for?(:panellist, program)
        pending_panellist << user
      else
        approved_panellist << user
      end
    end
    return pending_panellist.flatten, approved_panellist.flatten
  end

  def fetch_selectors(selectors, program)
    pending_selector, approved_selector = [],[]
    selectors.each do |user|
      if user.invited_for?(:selector, program)
        pending_selector << user
      else
        approved_selector << user
      end
    end
    return pending_selector.flatten, approved_selector.flatten
  end
  
  def notification_counts(program)
    cm_feeds_count = CommunityFeed.feed_for_program(program.id, ["all"]).for_pitch(nil).with_activities(false).not_by(current_user.id).where(:created_at => (current_user.last_sign_in_at)..Time.now).where(new_notifications(program, "program")[0] => new_notifications(program, "program")[1]).count
    invitations = current_user.pitch_invitations.count
    project_feed_count = project_feed_notifications_count(program)
    return cm_feeds_count+invitations+project_feed_count
  end

  def project_feed_notifications_count(program)
    project_feed_count = 0
    filter_pitches(program.try(:pitches)).each do |pitch|
      feed_counts = CommunityFeed.feed_for_pitch(program.id,pitch.id).with_activities(false).not_by(current_user.id).where(:created_at => (current_user.last_sign_in_at)..Time.now).where(new_notifications(program, "pitch")[0] => new_notifications(program, "pitch")[1]).count
      project_feed_count += feed_counts
    end
    return project_feed_count
  end

  def project_id_feeds_present(program)
    project_id_feeds_present = []
    filter_pitches(program.try(:pitches)).each do |pitch|
      feed_counts = CommunityFeed.feed_for_pitch(program.id,pitch.id).with_activities(false).not_by(current_user.id).where(:created_at => (current_user.last_sign_in_at)..Time.now).where(new_notifications(program, "pitch")[0] => new_notifications(program,"pitch")[1]).count
      (project_id_feeds_present << pitch.id) if feed_counts > 0 
    end
    return project_id_feeds_present
  end

  def feed_pitch(pitch_id)
    Pitch.find(pitch_id)
  end

  def feed_pitches(pitch_ids)
    pitches = []
    pitch_ids.each do |pitch_id|
      pitches << Pitch.find(pitch_id)
    end
    return pitches.flatten
  end

  def new_notifications(program, type)
    notification=[]
    if !current_user.visited_notifications.for_program_and_notification_type(program, type).blank? 
      notification[0] =  "created_at"
      notification[1] = ((current_user.visited_notifications.for_program_and_notification_type(program, type).try(:first).try(:created_at))..Time.now)
    else
      notification[0] =  "created_at.ne"
      notification[1] = nil
    end
    return notification
  end

  def filter_pitches(pitches)
    pitches.collect{|p| p if (p.team_and_mentor?(current_user.id.to_s) || current_user.role?("company_admin", p.try(:program).try(:organisation).try(:id).to_s))}.compact
  end

  def find_class(anchor)
    case anchor
    when "participant"
      "gn-icon-stack_applicant"
    when "mentor"
      "gn-icon-stack-mentor"
    when "pitch"
      "gn-icon-stack-idea"
    end
  end

  def find_role(anchor)
    case anchor
    when "participant"
      t("role_type:participant")
    when "mentor"
      t("role_type:mentor")
    when "pitch"
      t("pitch")
    end
  end  

  def get_tool_tip(anchor)
    case anchor
    when "participant"
      "#{t('role_type:participant')} form builder lets you customise the form #{t('role_type:participant', 'p')} have to fill in when registering"
    when "mentor"
      "#{t('role_type:mentor')} form builder lets you customise the form #{t('role_type:mentor', 'p')} have to fill in when registering"
    when "pitch"
      "#{t('pitch')} form builder lets you customise the various fields that make up the project #{t('role_type:participant', 'p')} are working on"
    end
  end

  def add_url_protocol(url)
    !(url[/\Ahttp:\/\//] || url[/\Ahttps:\/\//]) ? "http://#{url}" : url
  end

  def pitch_filter
    ary = []
    App::CustomFields::Models::CustomField.where(for_class: "Pitch", use_as_filter: true).each do |cf|
      cf.options.each do |op|
        ary << [op, cf.code]
      end
    end
    ary
  end
  
  def applicant_filter
    ary = []
     App::CustomFields::Models::CustomField.where(for_class: "User", use_as_filter: true, anchor: "participant").each do |cf|
      cf.options.each do |op|
        ary << [op, cf.code]
      end
    end
    ary
  end

  def is_image?(file)
    %w(.jpg .jpeg .gif .png .bmp).include?(File.extname(file)) 
  end

  def get_mentors(pitch)
    mentors = User.in("_mentor" => pitch.program.id.to_s).map(&:id)
    pitch_team = Pitch.find(pitch.id).team
    old_mentors = []
    pitch_team.each do |member|
      old_mentors << Moped::BSON::ObjectId.from_string(member)
    end
    required_mentors = User.in(id: (mentors - old_mentors)).map{|user| [user.full_name, user.id]}
  end

  def completed_activities
    activity_performances = current_user.activity_performances.where(:pitch_id=>@pitch.id)
    activity_performances.collect{|p| p if (((p.module_activity.activity_project_fields.blank? && p.module_activity.try(:action).blank?) && p.video_watch_status) || (p.status && p.video_watch_status))}.flatten.compact  
  end  

  def performed_activities
    current_user.activity_performances.where(:pitch_id=>@pitch.id)
  end

  def last_performed_activity_id
    performed_activities.sort_by(&:updated_at).try(:last).try(:module_activity).try(:id)
  end
    
  def percentage_calculation(x,y)
    (x.to_f/y.to_f)*100
  end
  
  def keywords_match(model_data)
    !params[:tag].blank? ?  params[:tag].split(",").to_set.intersection(model_data.keywords.to_set).present? : false
  end

  def find_pitches_not_mentored(user)
    pitches = context_program.pitches.where(:mentors.ne => user.id.to_s).map{|pitch| [pitch.title, pitch.id]}
  end

  def get_frequency(frequency)
    type = {"Once a day" => "day", "Once a week" => "week", "Once a month" => "month", "Never"=> "never"}
    type.key(frequency)
  end

  def notes_time_cal(seconds_time)
    seconds = seconds_time.to_i % 60
    minutes = (seconds_time.to_i / 60) % 60
    hours = seconds_time.to_i / (60 * 60)
    return hours > 0 ? format("%02d:%02d:%02d", hours, minutes, seconds) : format("%02d:%02d", minutes, seconds)
  end

  def video_or_asset_image(activity)
    if (activity.resource_format == "Video" || activity.resource_format == "External URL") && activity.link.present? 
      provider = vimeo_protocol_specific_url(activity.link)
      if !provider.blank? && provider[1] == "vimeo"
        image = activity.video_thumbnail         
      end 
    else
      if @activity.resource_format == "Image" 
        image = activity.attachment 
      end 
    end 
    return !image.blank? ? image : (@program.try(:program_summary).try(:lifestyle_background).try(:url).present? ? @program.program_summary.lifestyle_background.url : "/images/company.jpg")
  end

  def iteration_view(count)
    (count > 1 ? "#{count} Iterations" : "#{count} Iteration").html_safe 
  end  

  def feedback_view(count)
    (count > 1 ? "#{count} Feedbacks" : "#{count} Feedback").html_safe
  end

  def time_duration_of_event_session(event_session)
    time_from =  ("#{event_session.date}  #{event_session.time_from}").to_time
    time_to = ("#{event_session.date}  #{event_session.time_to}").to_time
    time_of_session = time_to - time_from
    "#{(Time.mktime(0)+time_of_session).hour} Hours " + "#{(Time.mktime(0)+time_of_session).min} Minutes"
  end

  def get_social_user_ankor(field)
    if field == "_awaiting_participant"
      return "participant"
    elsif field == "_awaiting_mentor"
      return "mentor"
    end
  end

  def check_social_media_fields(user)
    field = (current_user ? ((current_user.try(:attributes).try(:keys) & ["_awaiting_participant", "_awaiting_mentor"]).first) : nil)
    prog = field.present? ? Program.where(id: current_user.try(field).try(:first)).first : nil
    return field, prog
  end

  def get_custom_field_anchor_for_admin(user)
    field = (user ? ((user.try(:attributes).try(:keys) & ["_awaiting_participant", "_awaiting_mentor"]).first) : nil)
    if !!context_program
      if user.participant?(context_program)
        return "participant"
      elsif user.mentor?(context_program)
        return "mentor"
      elsif field.present?
        if field == "_awaiting_participant"
          return "participant"
        elsif field == "_awaiting_mentor"
          return "mentor"
        end
      end
    end
  end

  def all_super_admin
    User.where(:"_super_admin" => true)
  end

  def check_current_subdomain
    @program = Program.where(id: current_subdomain).first
    @program = get_domain_branding(request.host) if @program.nil?
    return @program
  end
  
  def event_session_rating(session, user)
    event_rating = session.event_ratings.where(:user_id => user.id).first
    if event_rating
      return event_rating.rating
    else
      return 0
    end
  end

  def vimeo_protocol_specific_url(activity_link)
    vimeo_http = activity_link.match(/http:\/\/(?:www.)?(vimeo).com\/(?:watch\?v=)?(.*?)(?:\z|&)/) 
    vimeo_https = activity_link.match(/https:\/\/(?:www.)?(vimeo).com\/(?:watch\?v=)?(.*?)(?:\z|&)/)
    return !vimeo_http.blank? ? vimeo_http : vimeo_https
  end
end
