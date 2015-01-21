class CommunityFeed
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sunspot::Mongoid2
  after_save :reindex_community_feed
  before_destroy :reindex_community_feed
  after_create :deliver_mail

  searchable do
    text :subject
    text :content
    string :program_id
    string :pitch_id
    boolean :activity
    text :comments do 
      comments.map { |comment| [comment.content, comment.children.map(&:content)] }
    end
    text :tags do 
      tags
    end
  end

  DEFINED_TAG = ["Questions", "Help needed", "Can help with", 
    "Classifieds", "Needs feedback", "Problems", "Learnings"]
  after_create :feed!
  after_destroy :unfeed!
  before_save :build_tags

  POST_TO = ["all", "participant", "mentor", "team", "team_and_mentor"]
  POST_TO_ADMIN = POST_TO[0..2]
  POST_TO_PARTICIPANT = [POST_TO[0],POST_TO[3..4]].flatten

  belongs_to :program
  belongs_to :organisation
  belongs_to :pitch
  belongs_to :milestone
  belongs_to :created_by, :class_name => "User"
  has_many :comments, :as => :commentable, :dependent => :destroy, :inverse_of => :commentable

  #INDEXES
  index({ program_id: 1 }, { background: true })
  index({ organisation_id: 1 }, { background: true })
  index({ created_by_id: 1 }, { background: true })
  index({ tags: 1 }, { background: true })
  index({ likes: 1 }, { background: true })

  attr_protected :likes, :featured, :likes_count

  field :content,           :type => String, :default => ""
  field :link,              :type => String, :default => ""
  field :tags,              :type => Array, :default => []
  field :likes,             :type => Array, :default => []
  field :likes_count,       :type => Integer, :default => 0
  field :featured,          :type => Boolean, :default => false
  field :post_to,           :type => String, :default => POST_TO[0]
  field :subject,           :type => String, :default => ""
  field :activity,          :type => Boolean, :default => false  
  field :add_to_blog,       :type => Boolean, :default => false
  field :sticky_post,       :type => Boolean, :default => false
  field :target,            :type => String, :default => ""
  field :target_type,       :type => String, :default => ""
  field :eco_blog,          :type => Boolean, :default => false
  mount_uploader :attachment, AttachmentUploader

  default_scope desc(:created_at)
  scope :for_program, lambda{|program| where(:program_id => program)}
  scope :for_organisation, lambda{|organisation| where(:organisation_id => organisation)}
  scope :for_pitch, lambda{|pitch| where(:pitch_id => pitch)}
  scope :for_milestone, lambda{|milestone| where(:milestone_id => milestone)}
  scope :by, lambda{|user| where(:created_by_id => user)}
  scope :have_tags, lambda{|tag| where(:tags.in => [tag])}
  scope :desc_sticky_post, unscoped.order_by(:sticky_post => :desc, :created_at=> :desc)
  scope :with_activities, lambda{|activity| where(:activity => activity)}
  scope :not_by, lambda{|user| where(:created_by_id.ne => user)}
  scope :without_target, lambda{|target_type| not_in(:target_type => [target_type])}

  validates :organisation_id, :created_by_id, :presence => true

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

  def feature!
    update_attribute(:featured, true)
  end

  def unfeature!
    update_attribute(:featured, false)
  end  

  def non_sticky!
    update_attribute(:sticky_post, false)
  end  

  def sticky!
    update_attribute(:sticky_post, true)
  end  

  def remove_from_blog!
    update_attribute(:add_to_blog, false)
  end  

  def add_to_blog!
    update_attribute(:add_to_blog, true)
  end

  def remove_from_eco_blog!
    update_attribute(:eco_blog, false)
  end  

  def add_to_eco_blog!
    update_attribute(:eco_blog, true)
  end

  #REDIS
  def feed!
    if defined?($redis)
      if program_id.present?
        $redis.sadd(self.class.redis_key("program", program_id), self.id.to_s)
      else
        $redis.sadd(self.class.redis_key("organisation", organisation_id), self.id.to_s)
      end
    end
  end

  def unfeed!
    if defined?($redis)
      if program_id.present?
        $redis.srem(self.class.redis_key("program", program_id), self.id.to_s)
      else
        $redis.srem(self.class.redis_key("organisation", organisation_id), self.id.to_s)
      end
    end
  end

  def self.feed_for_ecosystem(organisation_id)
  #   ids = $redis.smembers(self.redis_key("organisation", organisation_id))
  #   debugger
  #   where(:id.in => ids)
  # rescue
    for_organisation(organisation_id)#.for_pitch(nil).for
  end

  def self.feed_for_program(program_id, post_to = POST_TO[0])
    post_to = post_to.is_a?(Array) ? post_to : [post_to]
    prog = Program.where(id: program_id).first
    prog.community_feeds.in(post_to: post_to)
  #   ids = $redis.smembers(self.redis_key("program", program_id))
  #   where(:id.in => ids, :post_to.in => post_to)
  # rescue
  #   post_to = post_to.is_a?(Array) ? post_to : [post_to]
  #   for_program(program_id).where(:post_to.in => post_to)
  end

  def self.feed_for_pitch(program_id, pitch_id, post_to = POST_TO[0])
    feed_for_program(program_id, post_to).for_pitch(pitch_id)
  end

  def self.feed_for_milestone(program_id, milestone_id, post_to = POST_TO[0])
    feed_for_program(program_id, post_to).for_milestone(milestone_id)
  end

  def self.blog_feed_for_program(program_id, post_to = POST_TO[0])
    post_to = post_to.is_a?(Array) ? post_to : [post_to]
    #ids = $redis.smembers(self.redis_key("program", program_id))
    prog = Program.where(id: program_id).first
    prog.community_feeds.where(add_to_blog: true).in(post_to: post_to)
    #where(:id.in => ids, :post_to.in => post_to, :add_to_blog=>true)
  end

  def self.blog_feed_for_organisation(org_id, post_to = POST_TO[0])
    post_to = post_to.is_a?(Array) ? post_to : [post_to]
    org = Organisation.where(id: org_id).first
    org.community_feeds.where(eco_blog: true).in(post_to: post_to)
  end

  # helper method to generate redis keys

  def self.redis_key(resource, resource_id, key = nil)#POST_TO[0])
    ["#{self.to_s.underscore}",resource, resource_id,key].compact.join(":")
  end

  def build_tags
    self.tags = self.tags.split(",").flatten.collect(&:strip) if self.tags.present?
  end

  def admin_announcement(member_id, user_id, program_id)
      community_feed_id = self.id
      Resque.enqueue(App::Background::AdminAnnouncementMailer, member_id, community_feed_id, user_id, program_id)
  end

  def deliver_mail
    send_immediate_mail if !self.activity and !self.target_type.present?
  end

  def send_immediate_mail
    if self.pitch_id.present? && MailSetting.where(program: program).try(:first).try(:immediate_post_project_feed)
      pitch.pitch_team_and_admins.uniq.each do |user_id|
        Resque.enqueue(App::Background::ImmediatePostMailer, user_id, self.id, self.created_by_id, program.id, pitch.id)
      end
    elsif self.program_id.present? && MailSetting.where(program: program).try(:first).try(:immediate_post_program_feed)
      program.program_members_and_admins.uniq.each do |user_id|
        Resque.enqueue(App::Background::ImmediatePostMailer, user_id, self.id, self.created_by_id, program.id, nil)
      end
    end
  end

  def reindex_community_feed
    if self.changed?
      Resque.enqueue(App::Background::SolrIndexing, self.class.to_s, self.id)
    end
  end
  
  def check_for_achievement
    if !self.activity
      expired = false
      badge_rule = program.badge_rules.where(criteria: "buzzfeed", sub_criteria: "Post in buzz feed").first
      if badge_rule.present?
        case badge_rule.expiry
         when "fixed_date"
           Date.today <= badge_rule.expiry_date ? (expired = false): (expired = true)
         when "relative_date"
           ((Date.today - badge_rule.created_at.to_date) <= badge_rule.expiry_day) ? (expired = false): (expired = true)
        end
        if !expired
          user_badge = UserBadge.where(app_badge_id: badge_rule.app_badge.id, user_id: created_by_id).first
          user_badge.update_attributes(:iteration => user_badge.iteration + 1)
        end
      end
    end
  end

end
