require Rails.root.join('lib', 'devise', 'encryptors', 'md5')
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include App::Rolefy::Documents
  extend App::Rolefy::Scopes
  include Sunspot::Mongoid2
  include ActionView::Helpers
  include Mongoid::Paranoia
  
  after_save :reindex_users
  before_destroy :reindex_users, :delete_dependencies
  before_save :save_last_updated_by
  searchable do
    string :id
    text :email
    text :first_name
    text :last_name
    text :bio
    text :speciality
    text :skills do 
      skills
    end
    text :industry do 
      industry
    end
    text :education_qualification
    text :linkedin_profile
    text :organisation do 
      Organisation.where(:id => organisation).map{ |p| [p.company_name, p.description, p.industry, p.type, p.type_of]}    
    end
  end

  mount_uploader :avatar, AvatarUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :invitable, :async, :omniauthable, :encryptable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation,
  #     :remember_me, :salutation, :first_name, :last_name, :company_name,
  #     :job_title, :industry, :bio, :speciality, :interests, :skills, :education_qualification,
  #     :linkedin_profile, :nickname, :display_name, :approved, :avatar

  #INDEXES
  index({ email: 1 }, {  unique: true, background: true })
  index({ first_name: 1 }, { background: true })
  index({ last_name: 1 }, { background: true })
  index({ industry: 1 }, { background: true })
  index({ speciality: 1 }, { background: true })
  index({ skills: 1 }, { background: true })
  index({ interests: 1 }, { background: true })

  has_many :customize_admin_emails
  has_many :domain_maps
  has_many :answers
  has_many :pitch_invitations, foreign_key: 'invitee_id', class_name: 'PitchInvitation'
  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ##field to be used for account approval by moderators

  field :approved,            :type => Boolean, :default => false

  ## Confirmable
  field :confirmation_token,   :type => String
  field :confirmed_at,         :type => Time
  field :confirmation_sent_at, :type => Time
  field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  ##Invitable
  field :invitation_token, type: String
  field :invitation_created_at, type: Time
  field :invitation_sent_at, type: Time
  field :invitation_accepted_at, type: Time
  field :invitation_limit, type: Integer

  index( {invitation_token: 1}, {:background => true} )
  index( {invitation_by_id: 1}, {:background => true} )

  #Custom fields other than devise
  SALUTATION = ["Mr", "Mrs", "Miss", "Ms", "Dr", "Prof"]
  INDUSTRY =  [
                "Accounting", "Advertising", "Aerospace",
                "Agriculture", "Aircraft", "Airline",
                "Apparel & Accessories", "Automotive", "Banking",
                "Biotechnology", "Broadcasting", "Chemical",
                "Computer", "Consulting", "Consumer Product",
                "Cosmetics", "Defence", "Education", "Electronics",
                "Energy", "Entertainment & Leisure",
                "Financial Services", "Food & Beverage", "Grocery",
                "Health Care", "Internet Publishing", "Legal",
                "Manufacturing", "Motion Picture & Video", "Music",
                "Newspaper Publishers", "Pharmaceuticals",
                "Publishing","Real Estate", "Retail & Wholesale",
                "Software","Sports", "Technology", "Telecommunication",
                "Television", "Transportation", "Venture Capital"
              ]
  field :salutation,            :type => String
  field :first_name,            :type => String
  field :last_name,             :type => String, :default => ""  
  field :first_name_hidden,            :type => String
  field :last_name_hidden,             :type => String
  field :organisation,          :type => String
  field :company_name,          :type => String
  field :job_title,             :type => String
  field :industry,              :type => String
  field :bio,                   :type => String
  field :speciality,            :type => String
  field :skills,                :type => Array, :default => []
  field :interests,             :type => Array, :default => []
  field :education_qualification, :type =>String
  field :linkedin_profile,      :type => String

  field :nickname,              :type => String
  field :display_name,          :type => String
  field :provider
  field :uid
  field :linkedin_access_secret
  field :linkedin_access_token
  field :linkedin_id
  field :admin_update, :type => String, :default => ""
  field :last_admin_update, :type => Hash, :default => {}  
  field :anonymous, :type => Boolean, :default => false


  has_many :visited_faq_programs, :dependent => :destroy

  embeds_one :user_linkedin_connection, :class_name => 'User::LinkedinConnection'

  has_many :milestones, :dependent => :destroy
  has_one :basic_field_toggle
  has_many :activity_performances, :dependent => :destroy
  has_many :contact_requests, :class_name => "UserContactRequest", :foreign_key => :requester_id, :dependent => :destroy
  has_many :visited_notifications, :dependent => :destroy
  has_many :custom_events, :foreign_key => :created_by, :dependent => :destroy
  has_many :custom_reports, foreign_key: :creator, :dependent => :destroy
  has_many :event_ratings, :dependent => :destroy
  has_many :tokens, :dependent => :destroy
  has_many :user_badges, :dependent => :destroy
  #Validations
  # validates :first_name, :last_name, :presence => true  
  validates :first_name, :presence => true

  # method definitions
  def full_name
    [first_name, last_name].compact.join(" ");
  end

  def password_salt
    'no salt'
  end

  def password_salt=(new_salt)
  end

  def active_for_authentication?
    super && approved? 
  end 

  def inactive_message 
    if !approved? 
      :not_approved 
    else 
      super # Use whatever other message 
    end 
  end

  def approve!
    update_attribute(:approved, true)
  end

  def visible_programs
    return Program.all if super_admin?
    programs = RoleType.on_programs.collect{|t| self["_#{t.code}"]}.flatten.compact
    organisations = RoleType.on_organisation.collect{|t| self["_#{t.code}"] }.flatten.compact
    # org_programs = Program.in(:organisation_id => organisations)
    programs = Program.any_of({:id.in => programs}, {:organisation_id.in => organisations})
    # [org_programs, programs].flatten.uniq.compact
    programs
  end

  def self.accept_invitation!(user_params, options = {})
    if user_params[:invitation_token] == "0"
      user = User.where(id: options[:user_id]).first
      if user and ((user.confirmed? and user.approved?) or (!options[:current_user]))
        user
      else
        # user_params.delete(:invitation_token)
        user = User.new(user_params)
        begin
          user.skip_confirmation_notification!
          user.save!
        rescue Exception => e
          if e.message.include? "E-Mail is invalid"
            return "E-Mail is invalid."
          elsif e.message.include? "Password is too short"
            return "The password you entered is too short, password should be minimum 8 characters long."
          elsif e.message.include? "Password doesn't match confirmation"
            return "Your password does not match the confirm password. Please enter the same password in both fields."          
          else            
            return e.message
          end
        end
      end
    else
      user = where(:invitation_token => user_params.delete(:invitation_token)).last
      return false if user.blank?
      user.update_attributes(user_params)
      user.accept_invitation!
    end
    user.accept_and_approve!(options[:for], 
      options[:role_code], user_params[:invitation_token] == "0")
    user
  end

  def accept_and_approve!(resource, role, direct_invitation = false)
    program_role = RoleType.on_programs.collect(&:code).include?(role)
    org_role = RoleType.on_organisation.collect(&:code).include?(role)
    if program_role
      program = Program.where(id: resource).first
      manual_approval = (program and program.program_scope and program.program_scope.fields.include?("manual_approval_for_#{role}")) ? program.program_scope.try("manual_approval_for_#{role}") : false
    elsif org_role
      organisation = Organisation.where(id: resource).first
    end
    if invited_for?(role, resource)
      if program_role
        manual_approval ? awaiting_for_approval(role, resource) : add_role(role, resource)
      elsif
        add_role(role, resource)
      end
      if role == "company_admin"
        organisation.add_admin! self.id.to_s
      end
      remove_invite_role(role, resource)
      confirm!
      approve!
    elsif direct_invitation
      if program_role
        manual_approval ? awaiting_for_approval(role, resource) : add_role(role, resource)
      elsif
        add_role(role, resource)
      end
      if role == "company_admin"
        organisation.add_admin! self.id.to_s
      end
      approve!
    else 
      errors.add :base, "Invalid data"
    end
  end
  def self.welcome_messages(user_id, role, welcome_message, program_id)
    Resque.enqueue_in(10.seconds, App::Background::WelcomMessageMail, user_id, role, welcome_message, program_id)
  end

  def self.invitation_messages(parameters, resource, message, program_invitation_mail_id)
    program = resource
    domain_name=program.try(:program_scope).try(:email_restriction)
    RoleType.all.each do |role|
      code = role.code
      key = "invited_#{code}"
      invitation_message = key.present? ? invitee_message(key,message) : []
      invitation_mails = parameters[key.pluralize.to_sym].present? ? parameters[key.pluralize.to_sym].split(",").reject(&:blank?).collect(&:strip) : []
      resource = (key == "invited_program_admin" ? resource.organisation : program)
      invitation_mails.each do |email|
        result = true
        result = domain_name ? email.include?(domain_name) : true
        if email and email.strip.match Devise::email_regexp and result
          invitation_message(email, resource, code, invitation_message, program_invitation_mail_id)
        end
      end
    end
  end

  def self.invitation_message(email, resource, code, invitation_message, program_invitation_mail_id)
    user = User.invite!({:email => email, :skip_invitation => true})  do |u|
      u.skip_invitation = true
    end
    user.send(:generate_invitation_token) && user.save(:validate => false) if user.invitation_token.blank?
    user.invite_role(code, resource.id.to_s)
    Resque.enqueue(App::Background::InviteMemberByAdmin, user.id, resource.id, resource.class.to_s, code, invitation_message, program_invitation_mail_id)
  end


  def self.invite_users(parameters, resource)
    RoleType.on_programs.each do |role|
      code = role.code
      key = "invited_#{code}"
      invitation_mails = parameters[key.pluralize.to_sym].present? ? parameters[key.pluralize.to_sym].split(",").reject(&:blank?).collect(&:strip) : []
      invitation_mails.each do |email|
        if email and email.strip.match Devise::email_regexp
          invite_user(email, resource, code)
        end
      end
    end
  end

  def self.invite_user(email, resource, code)
    user = User.invite!({:email => email, :skip_invitation => true})  do |u|
      u.skip_invitation = true
    end
    user.send(:generate_invitation_token) && user.save(:validate => false) if user.invitation_token.blank?
    user.invite_role(code, resource.id.to_s)
    #background IT
    Resque.enqueue(App::Background::InvitationMailer, user.id, resource.id, resource.class.to_s, code)
  end

  def self.invite_user_admin(email, resource, code, invitation_message, admin_invitor_id)
    user = User.invite!({:email => email, :skip_invitation => true})  do |u|
      u.skip_invitation = true
    end
    user.send(:generate_invitation_token) && user.save(:validate => false) if user.invitation_token.blank?
    user.invite_role(code, resource.id.to_s)
    Resque.enqueue(App::Background::InvitationMailerToAdmin, user.id, resource.id, resource.class.to_s, code, invitation_message, admin_invitor_id)
  end

  def roles_string_for(program_id, company_id = nil)
    role_strings = []
    RoleType.all.each do |rt|
      role_strings << rt.code if super_admin? || role?(rt.code, program_id) || role?(rt.code, company_id)
    end
    role_strings.uniq
  end

  def role_code_for(program_id, company_id = nil)
    role_strings = []
    RoleType.all.each do |rt|
      role_strings << rt.code if role?(rt.code, program_id) || role?(rt.code, company_id)
    end
    role_strings.uniq
  end
  def self.organization_admin_invitation_email

  end

  def self.invitee_message(key,message)
    case key.present?
      when key == "invited_participant" then
        invitation_message = message[:applicant].try(:[],:applicant_invitee)
      when key == "invited_selector" then
        invitation_message = message[:selectors].try(:[],:selectors_invitee)
      when key == "invited_panellist" then
        invitation_message = message[:panel].try(:[],:panel_invitee)
      when key == "invited_mentor" then
        invitation_message = message[:mentors].try(:[],:mentors_invitee)
      when key == "invited_program_admin" then
        invitation_message = message[:program_admin].try(:[],:program_admin_invitee)
    end
    return invitation_message
  end
  def self.prelaunch_invitation_mail(email, resource, code,subject,message)
    user = User.invite!({:email => email, :skip_invitation => true})  do |u|
      u.skip_invitation = true
    end
    user.send(:generate_invitation_token) && user.save(:validate => false) if user.invitation_token.blank?
    user.invite_role(code, resource.id.to_s)
    Resque.enqueue(App::Background::ReminderUser,  user.id, resource.id, resource.class.to_s, code,subject,message)
  end

  def connect_to_linkedin(auth)
    self.provider = auth.provider
    self.uid = auth.uid
    self.user_linkedin_connection = User::LinkedinConnection.new(:token => auth["extra"]["access_token"].token, :secret => auth["extra"]["access_token"].secret)
    unless self.save
      return false
    end
    true
  end
   
  def disconnect_from_linkedin!
    self.provider = nil
    self.uid = nil
    self.user_linkedin_connection = nil
    self.save!
  end

  def self.find_for_linkedin_oauth(access_token, signed_in_resource=nil)

    secret = access_token.extra["access_token"].secret
    token = access_token.extra["access_token"].token
    id = access_token.extra["raw_info"].id
    email = access_token.extra.raw_info["emailAddress"]
    first_name = access_token.extra.raw_info["firstName"]
    last_name = access_token.extra.raw_info["lastName"]
    provider = access_token.provider
    client = LinkedIn::Client.new(AppConfig.linked_in["AppId"], AppConfig.linked_in["AppSecret"])
    client.authorize_from_access(token, secret)
    user_info = client.profile(:id => id, :fields => ["email-address", "first-name", "last-name", "headline", "industry", "picture-url", "public-profile-url", "location", "skills", "positions", "connections"])
    industry = user_info.industry
    location = user_info.location.name
    picture = user_info.picture_url
    company = nil
    user_info.positions.all.select{|c| company = c.company.name if c.is_current} if user_info.positions
    skills = user_info.skills.all.map(&:skill).map(&:name).join(', ') if user_info.skills
    user = User.where("linkedin_id"=>id)
    if user.present?
      user.first
    elsif signed_in_resource.present?
      signed_in_resource.update_attributes({:linkedin_access_secret =>secret,:linkedin_access_token=>token,:linkedin_id=>id})
    else
      begin
        user = self.new(:first_name => first_name, :last_name => last_name, :email => email, :username => id, :password => Devise.friendly_token[0,20],:linkedin_access_secret =>secret,:linkedin_access_token=>token, :linkedin_id=>id, :approved => true, :industry => industry, :skills => skills, :company_name => company, :remote_avatar_url => picture, provider:provider)
        user.skip_confirmation!
        user.save!
        user.confirm!
        return user
      rescue Exception => e
        return nil
      end
    end
  end

  def skills
    skills = read_attribute(:skills)
    skills.is_a?(Array) ? skills : []
  end

  def pitches_to_be_mentor mentor_id, program_id
    Program.find(program_id).pitches.where(user_id: self.id).select{|p| !p.mentor?(mentor_id.to_s)}
  end

  def self.find_for_facebook_oauth(auth)
    begin
      where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.password = Devise.friendly_token[0,20]
        user.first_name = auth.info.first_name
        user.last_name = auth.info.last_name
        user.approved = true
        user.skip_confirmation!
        user.save!
        user.confirm!
        return user
      end
    rescue Exception => e
      return nil
    end
  end

  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    first_name, last_name = auth.extra.raw_info.name.split(' ')
    bio = auth.extra.raw_info.description
    if user
      return user
    else
      registered_user = User.where(:email => auth.uid + "@twitter.com").first
      if registered_user
        return registered_user
      else
        user = User.new(first_name:first_name,
                            last_name: last_name,
                            provider:auth.provider,
                            uid:auth.uid,
                            password:Devise.friendly_token[0,20],
                            bio:bio,
                          )
        user
      end

    end
  end

  def self.rejection_message(user_id, role, program_id)
    Resque.enqueue(App::Background::RejectionMessageMail, user_id, role, program_id)
  end

  def self.message_to_admin_for_awaiting_users(user_id, role, program_id)
    Resque.enqueue(App::Background::MessageToAdmin, user_id, role, program_id)
  end

  def send_admin_welcome_message(user_id, org_id)
    Resque.enqueue(App::Background::SendWelcomeMessageToAdmin, user_id, org_id)
  end

  def self.to_csv(users, role, program, anchor)
    cf = User.custom_fields.where(program_id:program, anchor: anchor).map{|cc| [cc.label, cc.code]}
    header = ["Sno.", "role", "First Name", "Last Name", "Email", "Status", "Projects"]
    header << cf.map{|cc| cc[0]}
    CSV.generate do |csv|
      csv << header.flatten
      index = 0
      users.each do |user|
        index += 1
        status = user.user_status(user, program.id, role)
        projects = user.find_projects(user, program.id, role)
        unless projects.present?
          projects = "-"
        end
        data = [index, role.titleize, user.first_name, user.last_name, user.email, status, projects]
        code = cf.map{|cc| cc[1]}
        custom_fields = user.custom_fields.to_a
        values = []
        code.each do |code_data|
          if custom_fields.map{|cc| cc[0]}.include?(code_data)
            values << custom_fields.map{|cc| cc[1] if cc[0] == code_data}.compact
          else
            values << "-"
          end
        end
        data << values
        csv << data.flatten if user
      end
    end
  end

  def self.pitch_to_csv(pitches, program)
    cf = Pitch.custom_fields.where(program_id:program).map{|cc| [cc.label, cc.code]}
    header = ["S.no", "Title", "Stage", "Team Size (members/mentors)", "Number of updates"]
    header << cf.map{|cc| cc[0]}
    CSV.generate do |csv|
      csv << header.flatten
      index = 0
      pitches.each do |pitch|
        index += 1
        feed_count = pitch_feed_count(pitch)
        stage = find_active_phase_of_pitch?(pitch)
        members = count_team(pitch)
         data = [index, pitch.try(:title), stage, members, feed_count]
         code = cf.map{|cc| cc[1]}
         custom_fields = pitch.custom_fields.to_a
         values = []
        code.each do |code_data|
          if custom_fields.map{|cc| cc[0]}.include?(code_data)
            values << custom_fields.map{|cc| cc[1] if cc[0] == code_data}.compact
          else
            values << "-"
          end
        end
        data << values
        csv << data.flatten if pitch
      end
    end
  end

  def user_status(user, program_id,role)
    role_invite = "_invited_#{role}"
    role_rejected = "_rejected_#{role}"
    role_awaiting = "_awaiting_#{role}"
    if User.in( role_invite => program_id.to_s, id: user.id).first
      status = "Invited"
    elsif User.in( role_rejected => program_id.to_s, id: user.id).first
      status = "Rejected"
    elsif User.in( role_awaiting => program_id.to_s, id: user.id).first
      status = "Awaiting"
    else
      status = "-"
    end
  end

  def self.send_invitation_messages(invitations, program, invitation_mail_id)
      domain_name = program.try(:program_scope).try(:email_restriction)
      invitation_mail = ProgramInvitationMail.where(id: invitation_mail_id).first
      role = invitations["people_role"]
      invitation_message = role.present? ? invited_message(role,invitation_mail) : []
      invitation_mails = invitations[:invited_people].present? ? invitations[:invited_people].split(",").reject(&:blank?).collect(&:strip) : []
      resource = (role == "program_admin" ? program.organisation : program)
      invitation_mails.each do |email|
        result = true
        result = domain_name ? email.include?(domain_name) : true
        if email and email.strip.match Devise::email_regexp and result
          invitation_message(email, resource, role, invitation_message, invitation_mail_id)
        end
      end
  end

  def self.invited_message(role,invitation_mail)
    case role.present?
      when role == "participant" then
        invitation_message = invitation_mail.applicant_message["applicant_invitee"]
      when role == "selector" then
        invitation_message = invitation_mail.selectors_message["selectors_invitee"]
      when role == "panellist" then
        invitation_message = invitation_mail.panel_message["panel_invitee"]
      when role == "mentor" then
        invitation_message = invitation_mail.mentors_message["mentors_invitee"]
      when role == "program_admin" then
        invitation_message = invitation_mail.program_admins_message["program_admins_invitee"]
    end
    return invitation_message
  end

  def find_projects(user, program_id, role)
    program = Program.where(id: program_id).first
    user_pitches = []
    if program
      pitches = program.pitches
      if role == "participant"
        pitches.each do |pitch|
          if pitch.user_id == user.id or pitch.members.include?(user.id)
            user_pitches << pitch
          end
        end
      elsif role == "mentor"
        pitches.each do |pitch|
          if pitch.mentors.include?(user.id.to_s)
            user_pitches << pitch
          end
        end
      end
    end
    user_pitches = user_pitches.flatten.map(&:title).join(", ")
  end

  private

  def delete_dependencies
    CommunityFeed.where(created_by_id: id).delete_all
    PitchCustomFeedback.where(user_id: id.to_s).delete_all
    PitchFeedback.where(user_id: id.to_s).delete_all
    PitchCustomIteration.where(user_id: id.to_s).delete_all
    PitchDueDiligenceMatrix.where(panellist_id: id.to_s).delete_all
    ActivityFeed.where(user_id: id.to_s).delete_all
    PitchDocument.where(user_id: id.to_s).delete_all
    member_pitches = Pitch.or(:members => id.to_s).or(:mentors => id.to_s).or(:contacts => id.to_s).or(:membership_requesters => id.to_s).or(:collaborate_requesters => id.to_s).or(:collaboraters => id.to_s)
    member_pitches.each do |pitch|
      pitch.members = pitch.members - [id.to_s]
      pitch.mentors = pitch.mentors - [id.to_s]
      pitch.contacts = pitch.contacts - [id.to_s]
      pitch.membership_requesters = pitch.membership_requesters - [id.to_s]
      pitch.collaborate_requesters = pitch.collaborate_requesters - [id.to_s]
      pitch.collaboraters = pitch.collaboraters - [id.to_s]
      pitch.save!
    end
    Pitch.where(:user_id => id.to_s).delete_all
    organisations = Organisation.in(admins: id.to_s)
    organisations.each do |organisation|
      organisation.admins = organisation.admins - [id.to_s]
      organisation.save!
    end
  end


  def reindex_users
    if self.changed?
      Resque.enqueue(App::Background::SolrIndexing, self.class.to_s, self.id)
    end
  end
  
  def self.find_active_phase_of_pitch?(pitch)
    pitch.program.workflows.on.each do |workflow|
      unless workflow.pitch_phases.where(pitch_id: pitch.id).first
        code =  workflow.phase_name
        return code
      else
        "All Phases Completed"
      end
    end
  end
  
  def self.count_team(pitch)
    team = pitch.team_without_coll.count
    members = pitch.members.uniq.count
    mentors = pitch.mentors.uniq.count
    if team == (members + mentors)
      msg = "#{team}  (#{members} / #{mentors})"
    else
      members = members + 1;
      msg = "#{team}  (#{members} / #{mentors})"
    end
    msg
  end

  def self.pitch_feed_count(pitch, roles_string = nil)
    if roles_string
      CommunityFeed.in(program_id: pitch.program_id, pitch_id: pitch.id.to_s, :post_to.in => roles_string).count
    else
      CommunityFeed.in(program_id: pitch.program_id, pitch_id: pitch.id.to_s).count
    end
  end

  def save_last_updated_by
    if self.admin_update.present?
      self.last_admin_update = {}
      last_admin_update[self.admin_update] = self.changed
      last_admin_update["changed_at"] = Time.now
      self.admin_update = ""
    else
      self.last_admin_update = {}
    end
  end
end