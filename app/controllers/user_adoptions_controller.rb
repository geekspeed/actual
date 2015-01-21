class UserAdoptionsController < ApplicationController

  before_filter :load_program

  def edit
    @mail_setting = MailSetting.find_or_create_by(program: @program)
    @custom_reminders = @program.custom_reminders
  end

  def update
    @mail_setting = MailSetting.find_or_create_by(program: @program)
    if @mail_setting.update_attributes(params[:mail_setting])
      flash[:notice] = "Updated"
    else
      flash[:error] = "There are errors"
    end
    redirect_to action: :edit
  end

  private

  def load_program
    @program ||= Program.find(params[:program_id])
  end
end
