class SurveysController < ApplicationController


  def new
    @program= context_program
    @surveys= context_program.surveys.all
    @survey = context_program.surveys.build(organisation: current_organisation)
    @survey.build_question_order
  end

  def create
    survey = context_program.surveys.build(params[:survey])
    survey.organisation, survey.user= current_organisation, current_user
    if survey.save
      flash[:notice] = "Survey Successfully created"
      redirect_to new_survey_question_path(survey)
    else
      render :action => :new
    end
  end
  
  def edit
    @program=context_program
    @survey= context_program.surveys.find(params[:id])
    @questions=@survey.questions
    @survey.build_question_order unless @survey.question_order.present?
  end

  def update
    @survey = context_program.surveys.find(params[:id])
    @survey.update_attributes(params[:survey])
    @survey.create_questions params[:question]
    question_order = QuestionOrder.find_or_initialize_by(survey_id: @survey.id)
    question_order.update_attributes(:order => params[:order])
    flash[:notice] = "Updated Successfully"
    redirect_to :back
  end

  def destroy
    @survey = context_program.surveys.find(params[:id])
    @survey.destroy
    ActivityFeed.where(survey_id: params[:id]).delete_all
    redirect_to :back
  end

  def answers
    @survey = Survey.where(:id => params[:id]).first
    @program = @survey.program
    @survey.audience_started_survey << current_user.id unless (params[:redirected] or @survey.audience_started_survey.include? current_user.id)
    @survey.save
    render layout: "application_new_design"
  end
  
  def update_answers
    @survey = Survey.where(:id => params[:id]).first
    if params[:submit]
      @survey.audience_completed_survey << current_user.id unless @survey.audience_completed_survey.include? current_user.id
      @survey.audience_started_survey.delete(current_user.id)
      @survey.save
    end
    params[:survey][:custom_fields].each do|question_id, answer|
      ans = @survey.answers.find_or_initialize_by(question_id: question_id)
      ans.update_attributes(:answer_text=> answer, :user_id => current_user.id)
    end if params[:survey]
    redirect_to answers_program_survey_path(@survey.program, @survey, redirected: true)
  end

  def message_users
    survey = Survey.where(:id => params[:id]).first
    case params[:audience]
      when "completed"
        user_ids = survey.audience_completed_survey.uniq
      when "started"
        user_ids = survey.audience_started_survey.uniq
      when "not_completed"
        user_ids = survey.audience_not_completed
    end
    users = User.in(id: user_ids)
    requester = current_user.id
    Resque.enqueue(App::Background::SurveyMessageMail, params[:id], user_ids, requester, params[:subject], params[:message])
    redirect_to :back
  end
end