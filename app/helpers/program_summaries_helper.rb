module ProgramSummariesHelper
  
  def nav_links
    program = @program || context_program
    if program
      links = %w(program_plan goal entry_criteria partners quotes freeform judging_criteria freeform_html_1 freeform_html_2 freeform_html_3 blog)
      ordered_links = []
      links.each do|item|
        unless item == "freeform"
          ordered_links << item if eval("display_#{item}?")
        else
          if display_freeform?
            program.program_summary.program_free_forms.sort_by(&:created_at).each do|free_form|
              ordered_links << free_form.try(:section_title).parameterize("_") if (free_form.try(:section_title) and free_form.section_id.present?)
            end
          end
        end
      end
      ordered_links << ["contact-us", "custom_url"]
      ordered_links.flatten!
    end
  end

  def display_freeform_html_1?
    display_freeform_html? "freeform_html_1"
  end

  def display_freeform_html_2?
    display_freeform_html? "freeform_html_2"
  end

  def display_freeform_html_3?
    display_freeform_html? "freeform_html_3"
  end

  def link_name link
    link = ProgramNavLink.where(:url => link, :program_id => context_program.id).first
    link ? link.name : ""
  end
end