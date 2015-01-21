class ActivityFeed
  include Mongoid::Document
  include Mongoid::Timestamps
  after_create :generate_community_feed 

  belongs_to :program

  field :type, :type => String
  field :community_feed_id, :type => String
  field :pitch_id, :type => String
  field :user_id, :type => String
  field :survey_id, :type => String
  field :role_code, :type => String
  field :awaiting,  :type => Boolean, :default => false
  field :task_id,  :type => String
  field :feedback_id, :type => String
  field :response, :type => String, :default => "no response yet"
  field :due_diligence_id, :type => String
  field :post_due_diligence_ids, type: Array, default: []
  field :custom_event_id, :type => String
  field :mentor_id, :type => String
  field :message, :type => String
  field :event_rating_id, :type => String 
  field :user_badge_id, :type => String 

  def self.activity_feed_mail(program, mail_setting)
    @all_members = []
    RoleType.all.each do |rt|
      @users = User.in("_#{rt.code}" => program.id.to_s)
      @users.all.each do |user|
        @all_members << user
      end
    end
    program.organisation.admins.each do |admin_id|
      admin = User.find(admin_id)
      @all_members << admin
    end
    @all_members.flatten.uniq.each do |user|
      Resque.enqueue(App::Background::ActivityFeedsMail, program.id, user.id, mail_setting)
    end
  end
 
  def self.project_feed_mail(pitch, mail_setting)
    @all_members = []
    @all_members << pitch.user
    ms = MailSetting.where(program_id: pitch.program.id).first
    if ms and ms.admin_activity_feeds
      pitch.program.organisation.admins.each do |admin_id|
        admin = User.find(admin_id)
        @all_members << admin
      end
    end
    @all_members.flatten.uniq.each do |user|
      Resque.enqueue(App::Background::ProjectFeedsMail, pitch.id, user.id, mail_setting)
    end
  end

  def generate_community_feed
    unless self.type == "pitch_create_program"
      community_feed = CommunityFeed.create!(:organisation_id => self.program.organisation.id , :program_id => self.program_id, :activity => true, :post_to=> "all", :created_by_id=> self.user_id, :pitch_id => self.pitch_id)
      self.community_feed_id = community_feed.id
      self.save
    else
      community_feed = CommunityFeed.create!(:organisation_id => self.program.organisation.id , :program_id => self.program_id, :activity => true, :post_to=> "all", :created_by_id=> self.user_id)
      self.community_feed_id = community_feed.id
      self.type = "pitch_create"
      self.save
    end
  end
  
end
