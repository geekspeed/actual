class PitchBranchesController < ApplicationController
  before_filter :load_dependency
  skip_before_filter :authenticate_user!, :only => [:user_custom_branch_fields]

  def create
    @branch = @program.pitch_branches.build(params[:pitch_branch])
    if @branch.save
      flash[:notice] = "Branch saved"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  def update
    @branch = @program.pitch_branches.find(params[:branch_id])
    if @branch.update_attributes(params[:pitch_branch])
      flash[:notice] = "Branch Updated"
    else
      flash[:error] = "There are errors."
    end
    redirect_to :back
  end

  def branch_fields
    @pitch_branch = @program.pitch_branches.find_by(id: params[:branch_name])
    @custom_fields = Pitch.custom_fields_with_anchor("pitch").where(program_id: @program.id.to_s, branch_id: @pitch_branch.id.to_s).
                        select{|field| field if Workflow.where(program_id: @program.id.to_s, active: true, :code.in => field.phases).present?}
    render :partial => "shared/pitch_custom_fields_renderer"
  end

  def custom_branch_fields
    @custom_branch_field = true
    @custom_fields = Pitch.custom_fields_with_anchor("pitch").where(program_id: params[:program_id], parent_id: params[:option_id], parent_option: params[:option_name])
    render :partial => "shared/pitch_custom_fields_renderer"
  end

  def user_custom_branch_fields
    @custom_branch_field = true
    @custom_fields = User.custom_fields_with_anchor(params[:anchor]).where(program_id: params[:program_id], parent_id: params[:option_id], parent_option: params[:option_name])
    render :partial => "shared/user_custom_fields_renderer"
  end

  private

  def load_dependency
    @program = Program.find(params[:program_id])
  end
end