class EcosystemsController < ApplicationController

  skip_before_filter :authenticate_user!, :only => :show

  def index
    @ecosystems = Ecosystem.all
  end

  def show
    @ecosystem = Ecosystem.where(code: params[:id]).first
    @programs = @ecosystem.present? ? @ecosystem.programs : Program.all
    @pitches = @programs.collect(&:pitches).compact.flatten
  end

  def new
    @ecosystem = Ecosystem.new
  end

  def create
    @ecosystem = Ecosystem.new(params[:ecosystem])
    if @ecosystem.save
      flash[:notice] = "Ecosystem created successfully"
      redirect_to :back
    else
      render action: :new
    end
  end

  def destroy
    @ecosystem = Ecosystem.find(params[:id])
    if @ecosystem.programs.count.zero?
      @ecosystem.destroy
    else
      flash[:error] = "Can not desroy ecosystem as there are related programs"
    end
    redirect_to :back
  end
end
