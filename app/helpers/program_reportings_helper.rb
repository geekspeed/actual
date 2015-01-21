module ProgramReportingsHelper
  def selected_value(data, field)
    !data.blank? ? data[field] : ""
  end

  def chart_data(report_data, graph_type)
    filter = ProgramReport.report_fetch(report_data,context_program,current_organisation)
    if graph_type=="Line Chart" 
      filter_line_data(filter) 
    elsif graph_type=="Pie Chart"
      filter_pie_data(filter)
    end
  end

  def chart_table(report_data, graph_type)
    filter = ProgramReport.report_fetch(report_data,context_program,current_organisation)
    if graph_type=="Line Chart" 
      return filter[0]
    elsif graph_type=="Pie Chart"
      return filter_pie_data(filter)[0] 
    end
  end

  def filter_pie_data(filter)
    if filter.present?
      filter
    end
  end

  def filter_line_data(filter)
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
