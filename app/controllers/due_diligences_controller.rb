class DueDiligencesController < ApplicationController

  before_filter :load_due_diligence, :except => [:update, :create, :judging_score]

  def create
    @program = Program.find(params[:program_id])
    @due_diligence_matrix = @program.build_due_diligence_matrix(params[:due_diligence_matrix])
    if @due_diligence_matrix.save
      redirect_to edit_program_due_diligence_path(@program)
    else
      render :action => :new
    end
  end

  def update
    @program = Program.find(params[:program_id])
    @due_diligence_matrix = @program.due_diligence_matrix
    if @due_diligence_matrix.update_attributes(params[:due_diligence_matrix])
      flash[:notice] = "Program due diligence updated successfully."
      redirect_to :back
    else
      render :action => :edit
    end
  end

  def destroy
  end

  def judging_score
    @program = Program.find(params[:program_id])
  end
  
  def export_judging_details
    @program = Program.find(params[:program_id])
    csv_string = DueDiligenceMatrix.to_csv(@program)
    send_data csv_string,
    :type => 'text/csv; charset=iso-8859-1; header=present',
    :disposition => "attachment; filename=judging_score.csv"
  end
  
  private

  def load_due_diligence
    @program = Program.find(params[:program_id])
    if @program.due_diligence_matrix && @program.due_diligence_matrix.present? 
      @due_diligence_matrix = @program.due_diligence_matrix
      @matrices = []
      matrices_count = @due_diligence_matrix.matrices.count
      (15 - matrices_count).times{@matrices << @due_diligence_matrix.matrices.build} if matrices_count < 15
    else 
      @due_diligence_matrix = @program.build_due_diligence_matrix
      @matrices = []
      15.times{ @matrices << @due_diligence_matrix.matrices.build() }
    end
  end
end
