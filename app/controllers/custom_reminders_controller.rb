class CustomRemindersController < ApplicationController

  before_filter :load_program

  def create
    @custom_reminder = @program.custom_reminders.build(params[:custom_reminder])
    if @custom_reminder.save
      flash[:notice] = "Custom Reminder Created Successfully"
    else
      flash[:notice] = "Error Creating Custom Reminder"
    end
    redirect_to :back
  end

  def edit
    @custom_reminder = CustomReminder.find(params[:id])
  end
  
  def update
    @custom_reminder = CustomReminder.find(params[:id])
    if @custom_reminder.update_attributes(params[:custom_reminder])
      flash[:notice] = "Custom Reminder Updated Successfully"
    else
      flash[:notice] = "Error Updating Custom Reminder"
    end
    redirect_to edit_program_user_adoption_url(context_program)
  end
  
  def destroy
    @custom_reminder = CustomReminder.find(params[:id])
    if @custom_reminder.destroy
      flash[:notice] = "Custom Reminder Deleted Successfully"
    else
      flash[:notice] = "Error Deleting Custom Reminder"
    end
    redirect_to edit_program_user_adoption_url(context_program)
  end

  private

  def load_program
    @program ||= Program.find(params[:program_id])
  end
end
