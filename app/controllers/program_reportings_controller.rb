class ProgramReportingsController < ApplicationController
include ProgramReportingsHelper

  def index
    @reportings = context_program.reportings
  end

  def new_pie_chart
    if !params[:reporting].blank?
      filter = ProgramReport.report_fetch(params[:reporting],context_program,current_organisation)
      @graph_data =  filter_pie_data(filter) if filter.present?
    end
  end

  def new_line_chart
    if !params[:reporting].blank?
      filter = ProgramReport.report_fetch(params[:reporting],context_program,current_organisation)
      @table_data = filter[0] if filter.present?
      @graph_data =  filter_line_data(filter) if filter.present? 
    end
  end
  
  def saved_graphs
    @reportings = context_program.reportings
  end
  
  def phase_fields
    phases = context_program.workflows.collect{|p| ([p.code,p.phase_name] if p.active?)}.reject(&:blank?)
    respond_to do |format|
    format.json {render :json => phases}
    end
  end

  def filter_custom_field
    (filters = filter_fields("User","participant")) if params[:type] == "participants_filter"
    (filters = filter_fields("Pitch","pitch")) if params[:type] == "project_filter"
    respond_to do |format|
    format.json {render :json => filters}
    end
  end

  def save_graph
    @reporting = report_save
  end

  def add_to_dashboard
    params[:graph_attr][:dashboard] = true
    @reporting = report_save
  end

  def export_csv
    @report = context_program.reportings.where(:id=>params[:report_id]).first
    @graph_data = chart_csv_data(@report.reporting, @report.graph_type)
    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@graph_data[0]) }
    end
  end

  def export_csv_build
    @graph_data = chart_csv_data(params[:reporting], params[:graph_attr][:graph_type])
    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@graph_data[0]) }
    end
  end

  def show_chart
    @report = context_program.reportings.where(:id=>params[:report_id]).first
    @graph_data = chart_data(@report.reporting, @report.graph_type)
  end
  

  def remove_from_dashboard
    dashboard_report(false)
  end

  def added_to_dashboard
    dashboard_report(true)
  end

  def remove_report
    report = context_program.reportings.where(:id=>params[:report_id]).first
    report.destroy
    redirect_to :back
  end

  def report_branding
    if context_program.program_report_branding.blank?
      @report_brandings = context_program.build_program_report_branding
    else
      @report_brandings = context_program.program_report_branding
    end
  end

private
  def to_csv(csv_data)
    csv_string = CSV.generate do |csv|
      csv_data.each do |csv_content|
        csv << csv_content
      end
    end
  end

  def chart_csv_data(report_data, graph_type)     
    ProgramReport.report_fetch(report_data,context_program,current_organisation)
  end

  def filter_fields(model,anchor)
    filters = []
    custom_fields = model.constantize.custom_fields_with_anchor(anchor).enabled.for_program(get_program).filters.to_a
    custom_fields.each do |filter|
      filter.options.each_with_index do |option,index|
        filters << "#{filter.code}.#{option}"
        filters << "#{filter.label}  ::> #{option}"
      end
    end
    filters = Hash[*filters.flatten].to_a
  end

  def report_save
    params[:graph_attr][:reporting] = params[:reporting]
    context_program.reportings.new(params[:graph_attr])
  end

  def dashboard_report(flag)
    report = context_program.reportings.where(:id=>params[:report_id]).first
    report.dashboard = flag
    report.save
    redirect_to :back
  end

end
