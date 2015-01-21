class SearchController < ApplicationController
  def index
    search_results = []
    if params[:people] == "true"
      search_results << search_people.results
    end
    if params[:projects] == "true"
      search_results << search_pitches.results
    end
    if params[:content] == "true"
      search_results << search_community_feed.results
    end
    if params[:organisations] == "true"
      search_results << search_organisations.results
    end
    @results = search_results.flatten.sort_by(&:created_at).reverse
    @total_lines = @results.count
  end

private

  def search_pitches
    search_pitches = Pitch.search do
      fulltext params[:q]
      with :program_id, params[:id]
      paginate :page => 1, :per_page => Pitch.count
    end
  end

  def search_community_feed
    search_community_feed = CommunityFeed.search do
      fulltext params[:q]
      with :program_id, params[:id]
      with :pitch_id, nil
      without :activity, true
      paginate :page => 1, :per_page => CommunityFeed.count
    end
  end

  def search_people
    search_people = User.search do
      fulltext params[:q]
      with :id, program_users
      paginate :page => 1, :per_page => User.count
    end
  end

  def search_organisations
    search_organisations = Organisation.search do
      fulltext params[:q]
      with :id, org_ids
      paginate :page => 1, :per_page => Organisation.count
    end
  end


  def program_users
    @all_members = []
    RoleType.all.each do |rt|
      @users = User.in("_#{rt.code}" => context_program.id.to_s)
      @users.all.each do |user|
        @all_members << user
      end
    end
    context_program.organisation.admins.each do |admin_id|
      admin = User.find(admin_id)
      @all_members << admin
    end
    return @all_members.collect(&:id)
  end

 def org_ids
    users = []
    organisation_ids = []
    RoleType.all.each do |rt|
      users << User.in("_#{rt.code}" => context_program.id.to_s)
    end
    users = users.flatten.uniq
    organisation_ids << users.collect{|p| p.organisation}.reject(&:blank?).flatten
    organisation_ids << context_program.pitches.collect(&:organisation).reject(&:blank?)
    organisation_ids << context_program.try(:organisation).try(:id).to_s
    organisation_ids << current_organisation.try(:owner).try(:organisation)
    organisation_ids = organisation_ids.flatten.uniq.compact
  end

end
