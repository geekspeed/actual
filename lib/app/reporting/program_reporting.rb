class ProgramReport
	def self.report_fetch(reporting,program,organisation)
		case reporting["who_field_1"]
	  	when "participants"
	  		WhoField.who_people_field_two(reporting,program,organisation)
	  	when "projects"
	  		WhoField.who_projects_field_two(reporting,program,organisation)
	  	when "organisations"
	  		WhoField.who_organisations_field_two(reporting,program,organisation)
	  	end
	end

	def self.filter_pie_data(filter)
    if filter.present?
      filter
    end
  end

  def self.filter_line_data(filter)
    if filter.present?
      filter_array = []
      filter_array[0] = []
      filter_array[0][0] = filter[0].map{|k,v| v}.unshift(filter[2])
      filter_array[0][1] = filter[0].map{|k,v| k}.unshift("x")
      filter[0] = filter_array[0]
      filter
    end
  end
end
