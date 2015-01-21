class CustomReportsController < ApplicationController

  def new
    @program = Program.find(params[:program_id])
    @custom_report = @program.custom_reports.new
    @report_elements = @custom_report.custom_report_elements.new
    @pitch_fields = Pitch.custom_fields.where(program_id: context_program).map{|m| [m.label, m.id]}.uniq
    @user_fields = User.custom_fields.where(program_id: context_program).map{|m| [m.label, m.id]}.uniq
  end

  def create
    program = Program.find(params[:program_id])
    custom_report = program.custom_reports.build(params[:custom_report])
    custom_report.creator = current_user
    begin
      custom_report.save!
      flash[:notice] = "Report successfully created"
      redirect_to polymorphic_path([context_program, CustomReport])
    rescue Exception => e
      flash[:notice] = e.message
      redirect_to :back
    end
  end

  def index
    @program = Program.find(params[:program_id])
    @custom_reports = @program.custom_reports
  end

  def edit
    @program = Program.find(params[:program_id])
    @custom_report = @program.custom_reports.where(id: params[:id]).first
    @report_elements = @custom_report.custom_report_elements
    @pitch_fields = Pitch.custom_fields.where(program_id: context_program).map{|m| [m.label, m.id]}.uniq
    @user_fields = User.custom_fields.where(program_id: context_program).map{|m| [m.label, m.id]}.uniq
  end

  def update
    program = Program.find(params[:program_id])
    custom_report = program.custom_reports.where(id: params[:id]).first
    begin
      custom_report.update_attributes(params[:custom_report])
      redirect_to polymorphic_path([context_program, CustomReport])
    rescue Exception => e
      redirect_to :back
    end
  end

  def destroy
    program = Program.find(params[:program_id])
    custom_report = program.custom_reports.where(id: params[:id]).first
    begin
      custom_report.destroy
      redirect_to polymorphic_path([context_program, CustomReport])
    rescue Exception => e
      redirect_to :back
    end
  end

  def preview
    @program = Program.find(params[:program_id])
    @custom_report = @program.custom_reports.where(id: params[:id]).first
  end

  def delete_custom_element
    program = Program.find(params[:program_id])
    report_element = CustomReportElement.where(id: params[:id]).first
    report_element.destroy
    render :json => true
  end

  def send_report
    @report=CustomReport.find(params[:id])
    @prog_id=Program.find(params[:program_id])
    @user_id=current_user.id    
    Resque.enqueue(App::Background::SendReport, @user_id , @report.id, @prog_id.id)
    redirect_to :back    
  end

  def report_pdf
    if params[:report_id].present?
      custom_report = CustomReport.find(params[:report_id])
      pitch = Pitch.find(params[:pitch_id])
      file_name = custom_report.type == "Project" ? CustomReport.generate_individual_report(custom_report, context_program, current_organisation, pitch)
                                                    : CustomReport.generate_individual_report_participant(custom_report, context_program, current_organisation, pitch)
      File.open("#{Rails.root.to_s}/tmp/#{file_name}", 'r') do |f|
        send_data f.read, type: "pdf", disposition: "attachment"
      end
    else
      flash[:notice] = "Please select valid report"
      redirect_to :back
    end
  end

end
