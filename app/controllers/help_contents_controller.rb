class HelpContentsController < ApplicationController

  skip_before_filter :authenticate_user!, :only => [:show_help_content]

  def create
    program = Program.where(id: params[:program_id]).first
    program.help_contents.create!(params[:help_content])
    redirect_to :back
  end

  def update
    help_content = HelpContent.where(id: params[:id]).first
    help_content.update_attributes(params[:help_content])
    redirect_to :back
  end

  def show_help_content
    program = Program.where(id: params[:program_id]).first
    content = ""
    if program
      help_content = program.help_contents.for_custom_field(params[:custom_id]).where(field_name: params[:field_name], text_for: params[:text_for]).first
      content = help_content.try(:content)
    end
    render :json => {content: content}
  end
  
  def add_custom_ques
    @program = Program.where(id: params[:program_id]).first
    render :partial=> "questions/help_content", locals: {field_name: params[:field_name]}
  end
  
  def show_help_ques
    program = Program.where(id: params[:program_id]).first
    content = ""
    if program
      help_content = program.help_contents.where(field_name: params[:field_name]).first
      content = help_content.try(:content)
    end
    render :json => {content: content}
  end

  def add_custom_help
    @program = Program.where(id: params[:program_id]).first
    render :partial=> "customisations/help_content", locals: {field_name: params[:field_name], custom_field_id: params[:custom_field_id]}
  end
  
end