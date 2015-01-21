class ProgramReportBrandingsController < ApplicationController
  
  def create
  	report_branding = program_report_branding		 
  	redirect_to :back
  end 

private

  def program_report_branding	
  	if context_program.program_report_branding.blank?
  		branding_saved
  		branding_saved.save
  		flash[:notice] = "Report branding successfully saved"  		
  	else
  		branding_updated
  		flash[:notice] = "Report branding successfully updated"
  	end
  end

  def branding_saved
  	context_program.build_program_report_branding(params[:program_report_branding])
  end

  def branding_updated
  	context_program.program_report_branding.update_attributes(params[:program_report_branding])
  end

end
