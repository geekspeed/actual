module ProgramsHelper
  
  def display_resources?
    program = @program || context_program
    (!program.try(:resource_funding).blank? || !program.try(:likelihood_of_success).blank? || !program.try(:resource_mentoring).blank?)
  end
  
  def display_judging_criteria?
    program = @program || context_program
    (program.try(:due_diligence_matrix).present? && program.try(:due_diligence_matrix).try(:matrix_enable) == true) and program.try(:due_diligence_matrix).try(:matrices).present?
  end
  
  def display_quotes?
    program = @program || context_program
    (program.program_summary.try(:program_summary_customization).present? && program.program_summary.program_summary_customization.quotes == true) and program.program_summary.program_quotes.present?
  end
  
  def display_partners?
    program = @program || context_program
    (program.program_summary.try(:program_summary_customization).present? && program.program_summary.program_summary_customization.partners == true) and program.program_summary.program_partners.present?
  end
  
  def display_terms_and_conditions?
    program = @program || context_program
    (program.program_summary.present? && program.program_summary.try(:terms).present?) and (program.program_summary.try(:program_summary_customization).present? && program.program_summary.program_summary_customization.terms == true) and !@program.try(:program_summary).try(:terms_to_footer)
  end

  def display_entry_criteria?
    program = @program || context_program
    (program.program_summary.present? && program.program_summary.try(:entry_criteria).present?) and (program.program_summary.try(:program_summary_customization).present? && program.program_summary.program_summary_customization.entry_criteria == true)
  end

  def display_goal?
    program = @program || context_program
    (program.program_summary.present? && program.program_summary.try(:goal).present?) and (program.program_summary.try(:program_summary_customization).present? && program.program_summary.program_summary_customization.goal == true)
  end

  def display_program_plan?
    program = @program || context_program
    (program.program_summary.present? && (program.program_summary.program_plans.present? or !program.event_sessions.blank?) && ((program.program_summary.try(:program_plan_public) && !user_signed_in?) || user_signed_in?)) and (program.program_summary.try(:program_summary_customization).present? && program.program_summary.program_summary_customization.program_plan == true)
  end
  
  def display_freeform?
    program = @program || context_program
    (program.program_summary.try(:program_summary_customization).present? && program.program_summary.program_summary_customization.freeform == true && ((!user_signed_in? && program.program_summary.try(:program_free_form_public) || user_signed_in? ))) and program.program_summary.program_free_forms.present?
  end

  def program_blog_posts
    CommunityFeed.blog_feed_for_program(@program.id, ["all"]).for_pitch(nil)
  end

  def display_blog?
    !program_blog_posts.blank? && @program.try(:program_summary).try(:program_summary_customization).present? && @program.program_summary.program_summary_customization.blog == true
  end
  
  def display_freeform_html? title
    program = @program || context_program
    free_form = program.program_summary.program_free_forms.where(:section_id => nil, :section_title => title).first
    if free_form
      (program.program_summary.try(:program_summary_customization).present? && (title and eval("program.program_summary.program_summary_customization.#{title}") == true) && (free_form.body != "<p><br></p>"))
    else
      false
    end
  end
  
  def report_dropdown(prog)
    prog.custom_reports.or(:type => "Project").or(:type => "Participant").desc(:type)
  end
  
end