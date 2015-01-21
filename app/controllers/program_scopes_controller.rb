class ProgramScopesController < ApplicationController

  before_filter :load_program

  def new
    @scope = @program.build_program_scope
  end

  def create
    @scope = @program.build_program_scope(merge_tags)
    if @scope.save
      redirect_to edit_program_path(@program)
    else
      render :action => :new
    end
  end

  def edit
    @scope = @program.program_scope
  end

  def update
    @scope = @program.program_scope
    if @scope.update_attributes(merge_tags)
      flash[:notice] = "Program scope updated successfully."
      redirect_to :back
    else
      render :action => :edit
    end
  end

  private

  def load_program
    @program = Program.find(params[:program_id]) if params[:program_id].present?
  end

  def merge_tags
    params[:tags].present? ? params[:program_scope].merge(params[:tags]) : 
      params[:program_scope]
  end
end
