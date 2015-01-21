class WorkspaceController < ApplicationController
  
  before_filter :load_program

  def index  
    if context_program.workspace.blank?
      @workspace = context_program.build_workspace
    else
      @workspace = context_program.workspace
    end
  end

  def create
    if context_program.workspace.blank?
      workspace_saved
      workspace_saved.save
      flash[:notice] = "Workspace successfully saved"     
    else
      workspace_updated
      flash[:notice] = "Workspace successfully updated"
    end  
    redirect_to :back
  end 

private

  def workspace_saved
    context_program.build_workspace(params[:workspace])
  end

  def workspace_updated
    context_program.workspace.update_attributes(params[:workspace])
  end
  
  def load_program
    @program ||= Program.find(params[:program_id])
  end

end
