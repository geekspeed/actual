class DashboardsController < ApplicationController

  skip_before_filter :authenticate_user!, :only => [:main, :show]

  def show
    @pitches = !!context_program ? context_program.pitches : Pitch.all
    recommended_pitches_for_mentors_and_participants(@pitches)
    @pitches = @pitches.in(:tags => [params[:tags]]) if params[:tags].present?
    @count = Pitch.where(user_id: current_user.id).count if current_user
    render :layout => "application_new_design"
  end

  def main
    if params[:approved] 
      (flash_message = (params[:approved] == "true") ? 
      "Thanks for registering! Your can now access the program" : 
      "Thanks for registering! Your application is pending approval and you will be notified shortly")
      flash[:notice] = flash_message
    end
    if need?(["participant"], context_program) and user_signed_in?
      redirect_to :action => :my_work and return
    elsif user_signed_in?
      redirect_to :action => :show, :for => params[:for] and return
    else
      redirect_to :action => :show, :program_id => params[:program_id] and return if params[:login] == "false" 
      render :layout => "new_landing"
    end
  end

  def my_work
    @pitches = !!context_program ? context_program.pitches.or(:user_id => current_user.id.to_s).
                or(:members => current_user.id.to_s).or(:mentors => current_user.id.to_s) : []
    recommended_pitches_for_mentors_and_participants(@pitches)
    @pitches = @pitches.in(:tags => [params[:tags]]) if params[:tags].present?
    @count = Pitch.where(user_id: current_user.id).count if current_user
    if @pitches.count == 0
      redirect_to dashboard_path and return
    elsif @pitches.count == 1
      redirect_to program_pitch_path(context_program, @pitches.first) and return
    end
    render :action => :show, :layout => "application_new_design"
  end

  def people
    @users = []
    @organisation = current_organisation
    program_ids = @organisation.program_ids.collect(&:to_s)
    custom_keys = get_custom_fields
    if params[:code].blank?
      RoleType.all.each do |rt|
        @users << User.in("_#{rt.code}" => context_program.id.to_s)
        .any_of(custom_keys).to_a
      end
    else
      @users << User.where("_#{params[:code]}" => context_program.id.to_s)
      .any_of(custom_keys).to_a
    end
    @users = @users.compact.flatten.uniq.select{|s| s if !s.confirmed_at.nil?}
    
    if (need?(["participant"], context_program)) # only for participant
      pitches = context_program.pitches.where(user_id: current_user.id.to_s)
      recommended_mentors_for_participant(pitches)
    end
    render :layout => "application_new_design"
  end

  def filter_mentor
    users = []
    if params[:options]
      params[:options].each do |option|
        name, option = option.split(':')
        users << User.in(:"_mentor" => context_program.try(:id).to_s).where("custom_fields.#{name}" => option)
      end
      @users = users.flatten.compact.uniq
      render :action => :recommended_mentors, :layout => false
    else
      render :json => {status: "no"}
    end
  end

  def shortlisted_pitches
    workflows = Workflow.where(:code => "shortlisting", program_id: context_program.id.to_s)
    pitch_phases = []
    workflows.each do |workflow|
      pitch_phases << workflow.pitch_phases.map(&:pitch_id)
    end
    pitch_ids = pitch_phases.flatten.compact
    @pitches = context_program.pitches.in(id: pitch_ids)
    render :layout => "application_new_design"
  end

  def account_info
    user = User.where(id: params[:id]).first
    pitches = 0
    if user
      pitches = Pitch.or(:user_id => user.id.to_s).or(:members => user.id.to_s).or(:mentors => user.id.to_s).count
    end
    render :json => {pitch_count: pitches}
  end

  def delete_account
    user = User.where(id: params[:id]).first
    if user
      user.destroy
    end
    render :json => {}
  end

  def report_bug
    if simple_captcha_valid? or user_signed_in?
      organisation = current_organisation ? current_organisation.id : nil
      Resque.enqueue(App::Background::BugReportingMail, current_user.try(:email), params[:title], params[:description], organisation)
      render :json => true
    else
      render :json => false
    end
  end

  def ask_questions
    if simple_captcha_valid? or user_signed_in?
      organisation = current_organisation ? current_organisation.id : nil
      Resque.enqueue(App::Background::AskQuestionsMail, current_user.try(:email), params[:title], params[:description], organisation)
      render :json => true
    else
      render :json => false
    end
  end

  def recommended_pitches
    if params[:options].present?
      if params[:options].include? "all"
        @pitches = context_program.pitches
      elsif params[:options].include? "custom_filter"
        ankor = params[:options][1]
        @pitches = context_program.pitches
        find_pitches(@pitches, ankor)
      else
        pitches = []
        params[:options].each do |option|
          custom_field_options = current_user.custom_fields["#{option}"].nil? ? {:"custom_fields.#{option}".ne => nil} : {:"custom_fields.#{option}" => current_user.custom_fields["#{option}"]}
          pitches << context_program.pitches.or(:tags => option).or(:skills => option).or(custom_field_options)
        end
        @pitches = pitches.flatten.uniq
      end
      render :layout => false
    else
      render :json => {status: "no"}
    end
  end

  def recommended_mentors
    if params[:options].present?
      if params[:options].include? "all"
        @users = User.in("_mentor" => context_program.id.to_s)
      else
        users = []
        params[:options].each do |option|
          custom_field_options = current_user.custom_fields["#{option}"].nil? ? {:"custom_fields.#{option}".ne => nil} : {:"custom_fields.#{option}" => current_user.custom_fields["#{option}"]}
          users << User.in("_mentor" => context_program.id.to_s).or(:interests => option).or(:skills => option).or(custom_field_options)
        end
        @users = users.flatten.uniq
      end
      render :layout => false
    else
      render :json => {status: "no"}
    end
  end

  def organisations
    @organisation = current_organisation
    @organisations = Organisation.where(:id.in => org_ids)
    render :layout => "application_new_design" if params[:ecosystem] != "true"
  end

  def pitch_score_filter
    calculate = context_program.try(:due_diligence_matrix).try(:star_system) ? :rating : :points
    if params[:option] == "overall"
       @pitches = context_program.pitches.desc(calculate)
    else
      @pitches = PitchRating.where(matrix_id: params[:option]).desc(calculate).map(&:pitch)
    end
    render :action => :recommended_pitches, :layout => false
  end

  def assign_pitch_mentor
    user = User.find(params[:format])
    pitches = Pitch.in(:id => params[:pitches])
    pitches.each do |pitch|
     pitch.mentors << user.id.to_s
     pitch.save
     pitch.program.activity_feeds.create(:type=>"mentor_assigned", :user_id => current_user.id, :pitch_id=> pitch.id, :mentor_id => user.id)
    end
    flash[:notice] = "Assignment Successful"
    redirect_to :back
  end

  def destroy_user
    user = User.find(params[:id])
    if user and user.destroy
      flash[:notice] = "User deleted successfully"
      redirect_to dashboard_url
    else
      flash[:notice] = "Problem deleting user"
      redirect_to :back
    end
  end

  private

  def get_custom_fields
    custom_fields = {}
    if params[:match]
      pitch = Pitch.find(params[:match])
      filter_fields = Pitch.custom_fields.enabled
      .for_program(context_program).filters.collect(&:code)

      filtered = pitch.custom_fields.select{|k,v| 
        filter_fields.include?(k)}
      custom_fields = Hash[filtered.
        map {|k, v| ["custom_fields.#{k}", v] }]
    end

    custom_keys = params.dup
    custom_keys.delete(:code)
    custom_keys.delete(:action)
    custom_keys.delete(:controller)
    custom_keys.delete(:match)
    custom_keys.merge!(custom_fields)
  end

  def recommended_pitches_for_mentors_and_participants(all_pitches)
    custom_filter = context_program ? context_program.custom_filters.where(:ankor => "participant", rule_type: "custom_filter", is_private: true).first : nil
    if need?(["participant"], context_program) and custom_filter and !need?(["company_admin", "program_admin"], current_organisation)
      @pitches = Program.find_pitches(all_pitches, context_program, custom_filter, current_user)
    elsif ((need?(["mentor"], context_program) or (need?(["participant"], context_program) and custom_filter.try(:rule_type) == "project_recomendation")) and !need?(["company_admin"], current_organisation)) # only for mentor
      matched_tags = all_pitches.map(&:tags).flatten & current_user.skills
      matched_skills = all_pitches.map(&:skills).flatten & current_user.skills
      custom_fields = need?(["mentor"], context_program) ? User.custom_fields.enabled.for_program(context_program).filters.for_anchor("mentor") 
                      : User.custom_fields.enabled.for_program(context_program).filters.for_anchor("participant")
      pitch_custom_fields = Pitch.custom_fields.enabled.for_program(context_program).filters.for_anchor("pitch")
      matched_fields = custom_fields.map{|c| [c.label, c.code]} & pitch_custom_fields.map{|c| [c.label, c.code]}
      @match = (matched_skills + matched_tags + matched_fields).uniq
      @recommended_pitches = all_pitches.or(:tags.in => @match).or(:skills.in => @match) unless @match.empty?
      @js_match = (matched_skills + matched_tags).uniq
      filter_fields = custom_fields.map(&:code)
      get_filter_fields(filter_fields, all_pitches, matched_skills, matched_tags) unless filter_fields.empty?
      @pitches = @recommended_pitches.blank? ? @pitches : @recommended_pitches
    end
  end

  def recommended_mentors_for_participant(all_pitches)
    if params[:code] == "mentor"
      matched_tags = all_pitches.map(&:tags).flatten & @users.map(&:skills).flatten
      matched_skills = all_pitches.map(&:skills).flatten & @users.map(&:skills).flatten
      @match = (matched_skills + matched_tags).uniq
      @users = User.in(id: @users.map(&:id)).or(:interests.in => @match).or(:skills.in => @match) if (!@match.empty? && !@users.empty?)
      mentors = []
      f_fields = []
      all_pitches.map(&:custom_fields).each do |custom_field|
        custom_field.each do |cf|
          mentors << User.in("_mentor" => context_program.id.to_s).or(:interests.in => @match).or(:skills.in => @match).or(:"custom_fields.#{cf[0]}" => cf[1])
          f_fields << App::CustomFields::Models::CustomField.for_class(User).where(program_id: context_program.id.to_s, code: cf[0])
        end
      end
      @match = mentors.flatten.empty? ? [] : (matched_skills + matched_tags + f_fields.flatten.uniq.map{|cf| [cf.label, cf.code]}).uniq
      @js_match = mentors.flatten.empty? ? [] : (matched_skills + matched_tags + f_fields.flatten.uniq.map(&:code)).uniq
      @users = mentors.flatten.uniq unless mentors.flatten.empty?
    end
  end

  def org_ids
    users = []
    organisation_ids = []
    RoleType.all.each do |rt|
      users << User.in("_#{rt.code}" => context_program.id.to_s)
    end
    users = users.flatten.uniq
    organisation_ids << users.collect{|p| p.organisation}.reject(&:blank?).flatten
    organisation_ids << context_program.pitches.collect(&:organisation).reject(&:blank?)
    organisation_ids << context_program.try(:organisation).try(:id).to_s
    organisation_ids << current_organisation.try(:owner).try(:organisation)
    organisation_ids = organisation_ids.flatten.uniq.compact
  end
  
  def get_filter_fields(filter_fields, all_pitches, matched_skills, matched_tags)
    pitches = []
    f_fields = []
    filter_fields.each do |option|
      pitches << all_pitches.or(:tags.in => @match).or(:skills.in => @match).or(:"custom_fields.#{option}" => current_user.custom_fields["#{option}"])
      f_fields << App::CustomFields::Models::CustomField.for_class(Pitch).where(program_id: context_program.id.to_s, code: option)
    end
    @js_match = (matched_skills + matched_tags + f_fields.flatten.map(&:code)).uniq
    @recommended_pitches = pitches.flatten.uniq unless pitches.empty?
  end
  
  def find_pitches(pitches, ankor)
    custom_filter = context_program.custom_filters.where(:ankor => ankor).first
    custom_filter.custom_rules.each do |rule|
      event = ProgramEvent.find(rule.event_for.to_s)
      users = event.event_sessions.map(&:event_records).flatten.map(&:user).map(&:id).map(&:to_s)
      users.present? ? (user_pitches = Pitch.or(user_id: users).or(mentors: users).or(members: users)) : (user_pitches = [])
      pitches_found = rule.role == "Participated In" ? user_pitches : (Pitch.nin(id: user_pitches))
      if rule.field_name == "Tag"
        @pitches = @pitches & pitches_found.in(:tags => rule.field_value)
      else
        code = Pitch.custom_fields.where(:id => rule.field_name).first.try(:code)
        value = rule.field_value
        @pitches = @pitches & pitches_found.where("custom_fields.#{code}" => value)
      end
    end
    @pitches = @pitches.flatten.uniq
  end

end
