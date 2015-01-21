class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  after_save :reindex_community_feed,:comment_new_line
  before_destroy :reindex_community_feed

  after_create :deliver_mail

  field :content,         :type => String, :default => ""
  field :likes,           :type => Array,  :default => []
  field :likes_count,     :type => Integer, :default => 0
  belongs_to :parent, :class_name => "Comment", :inverse_of => :children
  has_many :children, :class_name => "Comment", :inverse_of => :parent, :foreign_key => :parent_id

  #INDEXES
  index({ parent_id: 1 }, { background: true })
  index({ commentable_id: 1 }, { background: true })
  index({ commentable_type: 1 }, { background: true })

  attr_protected :likes, :likes_count

  belongs_to :commentable, :polymorphic => true
  belongs_to :commented_by, :class_name => "User"

  def liked_by
    User.in(:id => likes)
  end

  def liked_by?(user)
    user_id = user.respond_to?(:id) ? user.id : user
    likes.include?(user_id)
  end

  def like!(user)
    user_id = user.respond_to?(:id) ? user.id : user
    likes << user_id
    inc(:likes_count,1)
    save!
  end

  def unlike!(user)
    user_id = user.respond_to?(:id) ? user.id : user
    existing = likes
    existing.delete(user_id)
    update_attribute(:likes, existing)
    inc(:likes_count, -1)
  end

  def deliver_mail
    Resque.enqueue(App::Background::CommunityFeedMailer, 
      "comments", self.id, self.commenter)
  end 

  def commenter
    if commentable.respond_to?(:created_by_id)
      commentable.created_by_id
    elsif commentable.respond_to?(:commented_by_id)
      commentable.commented_by_id
    else
      nil
    end
  end

  def comment_new_line
    self.content = self.content.gsub(/\n/, '<br/>')
    self.touch
  end

  def reindex_community_feed
    if self.changed?
      community_feed = !self.parent.blank? ? self.parent.commentable : self.commentable
      Resque.enqueue(App::Background::SolrIndexing, community_feed.class.to_s, community_feed.id)
    end
  end
end
