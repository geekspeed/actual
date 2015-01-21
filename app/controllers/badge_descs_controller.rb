class BadgeDescsController < ApplicationController
  
  skip_before_filter :authenticate_user!
  
  def show
    @desc = BadgeDesc.find(params[:id])
    @badge_rule = @desc.app_badge.badge_rule
  end
end