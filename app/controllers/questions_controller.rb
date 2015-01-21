class QuestionsController < ApplicationController

  def new
    @program=context_program
    @survey = context_program.surveys.where(id: params[:survey_id]).first
    @question = @survey.questions.build(user: current_user)
    @questions = @survey.questions
    @survey.build_question_order unless @survey.question_order.present?
  end

  def create
    @survey = context_program.surveys.where(id: params[:survey_id]).first
    @survey.create_questions params[:question]
    question_order = QuestionOrder.find_or_initialize_by(survey_id: @survey.id)
    question_order.update_attributes(:order => params[:order])
    redirect_to :back
  end

  def destroy
    ques = Question.where(id: params[:id]).first
    ques.destroy
    redirect_to :back
  end
  
end