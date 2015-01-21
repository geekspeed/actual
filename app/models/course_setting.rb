class CourseSetting
  include Mongoid::Document
  include Mongoid::Timestamps
  field :user_section, type: String, default: "my_work_community"
  field :inactive_user, type: String
  field :inactive_user_message, type: String
  field :automated_inactive_email, type: Boolean, default: false
  field :user_privacy, type: Boolean, default: false
  belongs_to :program


  def self.user_reminder_mail(program, course_setting)
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
      if (Time.now - user.updated_at) > course_setting.inactive_user.to_i
        Resque.enqueue(App::Background::InactiveUserMail, program.id, user.id, course_setting.id)
      end
    end
  end
end
