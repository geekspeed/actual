class SettingsController < ApplicationController

  before_filter :load_program

  def new
    @semantics = Semantic.defaults
  end

  def create
    params[:semantics].each do |key, semantic|
      Semantic.for_program(@program.id).find_or_create_by(key: 
        key).update_attributes(semantic)
    end
    redirect_to :back
  end

  def cloneable
    if @program.master_program?
      @setting = MasterSetting.find_or_create_by(program_id: @program.id)
      @setting.update_attributes(params[:settings])
      request.xhr? ? (render json: @setting) : redirect_to(:back)
    else
      request.xhr? ?  (render json: { status: "not a master program" })  : redirect_to(:back)
    end
  end

  private 

  def load_program
    @program ||= Program.find(params[:program_id])
  end
end
