class FaqsController < ApplicationController

  before_filter :load_program

  def new
    @faq = @program.faqs.new
    if params[:role].present?
      @faqs = @program.faqs.where(role_code: params[:role])
    else
      @faqs = @program.faqs.all.asc(:created_at)
    end
  end

  def create
    @program = @program.update_attributes(params[:program][:faqs_attributes])
    if @program.save
      redirect_to  edit_program_path(@program)
    else
      redirect_to "/programs/#{@program.id}/faqs/new"
    end
  end



  def update
    @faq = Faq.find(params[:id])

    if @faq.update_attributes(params[:faq])
      redirect_to :back
    else
      render :action=> :new
    end
  end

  def destroy
    if params[:id].present?
      faq = Faq.where(id: params[:id]).first
      if faq.destroy
        redirect_to "/programs/#{@program.id}/faqs/new"
      else
        redirect_to "/programs/#{@program.id}/faqs/new"
      end
    end
  end


  def show
    @faqs = @program.faqs.all
  end


  private

  def load_program
    @program = Program.find(params[:program_id])
  end

end