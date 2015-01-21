class BadgesController < ApplicationController

  before_filter :load_program

  def index
    @badges = @program.app_badges
  end

  def new
    @app_badge = @program.app_badges.new
    @app_badge.build_badge_rule 
  end

  def create
    unless !!current_organisation.badge_authority
     current_organisation.create_badge_authority(name: current_organisation.try(:company_name), url: organisation_url(current_organisation))
    end 
    badge = @program.app_badges.new(params[:app_badge])
    if badge.save
      program_users = User.or(:"_participant".in=> [context_program.id.to_s]).or(:"_mentor".in=> [context_program.id.to_s]).or(:"_selector".in=> [context_program.id.to_s]).or(:"_panellist".in=> [context_program.id.to_s]).flatten.uniq.map(&:id).map(&:to_s)
      program_users.each do |user|
        user_badge = UserBadge.create(user_id: user, app_badge_id: badge.id)
      end
      desc = badge.create_badge_desc
      desc = desc.update_attributes(:url => badge_desc_path(desc))
      flash[:notice] = "Batch added succcessfully"
    else
      flash[:notice] = "Problem adding badge. Badge with this criteria may already be present."
    end
    redirect_to  action: :index
  end

  def edit
    @app_badge = AppBadge.find(params[:id])    
    @badge_rule = @app_badge.badge_rule
    @selected = @badge_rule.sub_criteria
    criteria = @badge_rule.criteria.titleize.to_s
    @options = ("BadgeRule::#{criteria}").safe_constantize
  end

  def update
    app_badge=AppBadge.find(params[:id])
    if app_badge.update_attributes(params[:app_badge])
      flash[:notice] = "Batch updated succcessfully"
    else
      flash[:notice] = "Problem to update a batch"
    end
    redirect_to  action: :index

  end

  def destroy
    @app_badge = AppBadge.in(id: params[:id])
    @app_badge.destroy
    redirect_to  action: :index
  end

  def show_badge
    @app_badge = AppBadge.in(id: params[:id]).first
  end

  def issue_manual_badge
    badge = AppBadge.find(params[:id])
    if params[:badges_for].present?
      params[:badges_for].each do |user|
        user_badge = badge.user_badges.where(:user_id => user).first
        user_badge.update_attributes(:active => true)
      end
    end
    redirect_to :back
  end

  private

  def load_program
    @program = Program.find(params[:program_id])
  end

end