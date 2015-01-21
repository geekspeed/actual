class DocumentsController < ApplicationController
  before_filter :load_dependency

  def index
    @documents = @pitch.documents
    @document = PitchDocument.new
    render layout: "application_new_design"
  end

  def create
    @document = @pitch.documents.build(params["pitch_document"])
    @document.user = current_user
    if @document.save
      flash[:notice] = "Document saved successfully"
    else
      flash[:error] = "There are errors"
    end
    redirect_to :action => :index
  end

  def destroy
    @document = @pitch.documents.find(params[:id])
    @document.destroy
    redirect_to :action => :index
  end

  def approve
    @document = @pitch.documents.find(params[:id])
    if @pitch.mentor?(current_user)
      @document.approve!(current_user)
      flash[:notice] = "Document approved"
    else
      flash[:error] = "There are errors"
    end
    redirect_to :back
  end

  private

  def load_dependency
    @program = Program.find(params[:program_id])
    @pitch = @program.pitches.find(params[:pitch_id])
  end
end
