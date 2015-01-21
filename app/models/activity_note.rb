class ActivityNote
  include Mongoid::Document
  include Mongoid::Timestamps

  after_create :generate_community_feed
  after_update :update_community_feed
  before_destroy :delete_community_feed

  field :video_watch_duration, type: String, default: ""
  field :notes, type: String, default: ""
  belongs_to :activity_performance
  belongs_to :community_feed

  def generate_community_feed
  	Resque.enqueue(App::Background::GenerateCommunityFeed, self.id)
  end
   
  def update_community_feed
  	Resque.enqueue(App::Background::UpdateCommunityFeed, self.id)
  end  

  def delete_community_feed
  	Resque.enqueue(App::Background::DeleteCommunityFeed, self.community_feed_id)
  end

end
