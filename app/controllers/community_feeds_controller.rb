require 'embedly'
class CommunityFeedsController < ApplicationController

  before_filter :load_dependencies

  def index
    @cm_feeds = CommunityFeed.feed_for_program(@program.id, ["all"]).for_pitch(nil).desc_sticky_post.without_target("es").page(params[:page])
    @cm_feeds = @cm_feeds.in(tags: params[:tag]) if params[:tag].present?
    render :layout => "application_new_design"
  end

  def show
    @feed = CommunityFeed.find(params[:id])
    render :layout => "application_new_design"
  end

  def create
    #TODO: needs to be refactored, as creating milestone 
    #from community feed is not a good way
    target_type = params[:community_feed][:target_type]
    if params[:post_milestone] == "true"
      context_program.pitches.each do |pitch|
        pitch.milestones.create(
          description: params[:community_feed][:content]
        )
      end if params[:community_feed][:content].present?
    else
      @community_feed = CommunityFeed.new(params[:community_feed])
      @community_feed.created_by = current_user
      @community_feed.organisation = current_organisation
      @community_feed.program = context_program || @program
      if @community_feed.save
       if params[:community_feed][:post_to].present? && !params[:community_feed][:pitch_id].present?
         if current_user.role?("company_admin", @program.organisation.id.to_s) || current_user.role?("super_admin", @program.organisation.id.to_s)
          admin_announcement_call()
         end
       end
       if target_type.present?
         if  target_type == "es" and params[:community_feed][:target].present?
           if current_user.role?("company_admin", @program.organisation.id.to_s) || current_user.role?("super_admin", @program.organisation.id.to_s)
            message_all()
           end
          elsif target_type == "bfea"
            message_all_users()
          end
       end
        flash[:notice] = "Feed saved successfully"
      else
        flash[:error] = "There are errors."
      end
    end
    redirect_to :back
  end

  def destroy
    @feed = CommunityFeed.find(params[:id])
    @feed.destroy
    redirect_to :back
  end

  def like
    @feed = CommunityFeed.find(params[:id])
    @feed.like!(current_user)
    request.xhr? ? (render :json => {success:"OK", likes_count: @feed.likes_count}) : redirect_to(:back)
  end

  def unlike
    @feed = CommunityFeed.find(params[:id])
    @feed.unlike!(current_user)
    request.xhr? ? (render :json => {success:"OK", likes_count: @feed.likes_count}) : redirect_to(:back)
  end

  def feature
    @feed = CommunityFeed.find(params[:id])
    @feed.feature!
    redirect_to :back
  end

  def unfeature
    @feed = CommunityFeed.find(params[:id])
    @feed.unfeature!
    redirect_to :back
  end  

  def non_sticky
    @feed = CommunityFeed.find(params[:id])
    @feed.non_sticky!
    redirect_to :back
  end  

  def sticky
    @feed = CommunityFeed.find(params[:id])
    @feed.sticky!
    redirect_to :back
  end  

  def remove_from_blog
    @feed = CommunityFeed.find(params[:id])
    @feed.remove_from_blog!
    redirect_to :back
  end  

  def add_to_blog
    @feed = CommunityFeed.find(params[:id])
    @feed.add_to_blog!
    redirect_to :back
  end

  def remove_from_eco_blog
    @feed = CommunityFeed.find(params[:id])
    @feed.remove_from_eco_blog!
    redirect_to :back
  end  

  def add_to_eco_blog
    @feed = CommunityFeed.find(params[:id])
    @feed.add_to_eco_blog!
    redirect_to :back
  end

  def like_from_mail
    @feed = CommunityFeed.find(params[:id])
    if @feed.likes.include?(current_user.id)  
      flash[:notice] = "You have already liked the post"
    else 
      @feed.like!(current_user)
      flash[:notice] = "You have liked the post"
    end 
    redirect_to polymorphic_url([@feed.program, @feed.pitch, @feed])
  end

  private

  def load_dependencies
    @program = Program.find(params[:program_id]) if params[:program_id]
    @pitch = Pitch.find(params[:pitch_id]) if params[:pitch_id]
  end

  def admin_announcement_call
        if params[:community_feed][:post_to] == "all"
        RoleType.all.each do |rt|
        @users = User.in("_#{rt.code}" => params[:program_id]).to_a
          @users.each do |member|
            @community_feed.admin_announcement(member.id, current_user.id, params[:program_id])
          end
        end
      else 
        @users = User.in("_#{params[:community_feed][:post_to]}" => params[:program_id]).to_a
          @users.each do |member|
             @community_feed.admin_announcement(member.id, current_user.id, params[:program_id])
          end
      end
  end

  def message_all
    @users = Targetting.find_users(params[:community_feed][:target], params[:program_id])
    @users.each do |member|
      @community_feed.admin_announcement(member, current_user.id, params[:program_id])
    end
  end

  def message_all_users
    program = Program.find(params[:program_id])
    users = User.or(:"_participant".in=> [context_program.id.to_s]).or(:"_mentor".in=> [context_program.id.to_s]).or(:"_selector".in=> [context_program.id.to_s]).or(:"_panellist".in=> [context_program.id.to_s]).flatten.uniq.map(&:id)
    users.each do |member|
      @community_feed.admin_announcement(member, current_user.id, params[:program_id])
    end
  end
end
