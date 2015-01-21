module SearchHelper
  def selected(search_type)
    no_option_selected ? (!params[search_type].blank? ? true :  false) : true
  end
  def no_option_selected
    !params[:people].blank? || !params[:projects].blank? || !params[:content].blank? || !params[:organisations].blank?
  end
  
  def search_criteria_select
    !params[:people].blank? ? "people" : (!params[:projects].blank? ? "projects" : (!params[:organisations].blank? ? "organisations" : "contents"))
  end 

  def search_criteria_count
    search_criteria = []
    (search_criteria << params[:people] << params[:projects] << params[:content] << params[:organisations]).compact.count == 1
  end

  def search_details
    if search_criteria_count
      "Your search - <b>#{params[:q]}</b> - did not bring any #{search_criteria_select}".html_safe
    elsif no_option_selected
      "Your search - <b>#{params[:q]}</b> - did not bring any results".html_safe
    else
      "No results found: You did not select any search criteria"
    end
  end
end
