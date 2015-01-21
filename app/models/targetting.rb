class Targetting
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,  :type => String,  :default => ""
  field :role,  :type => String,  :default => ""
  field :project_phase_achived,  :type => String,  :default => ""
  field :project_phase_not_achived,  :type => String,  :default => ""
  field :last_activity,  :type => Integer,  :default => 0
  field :pitch_filter_code,  :type => String,  :default => ""
  field :pitch_filter_option,  :type => String,  :default => ""
  field :applicant_filter_code,  :type => String,  :default => ""
  field :applicant_filter_option,  :type => String,  :default => ""
  field :explaination,  :type => String,  :default => ""
  field :is_default, :type => Boolean, :default => false
  field :joined_team_filter,  :type => Integer,  :default => 0

  validates :name, :presence => true

  belongs_to :program

  def self.to_csv(users)
    users = User.in(id: users)
    CSV.generate do |csv|
      csv << ["Sno.", "First Name", "Last Name"]
      index = 0
      users.each do |user|
        index += 1
        csv << [index, user.first_name, user.last_name] if user
      end
    end
  end

  def self.pitch_to_csv(pitches)
    pitches = Pitch.in(id: pitches)
    CSV.generate do |csv|
      csv << ["Sno.", "Title"]
      index = 0
      pitches.each do |pitch|
        index += 1
        csv << [index, pitch.title] if pitch
      end
    end
  end

  def self.find_users(target, program_id)
    targetting = Targetting.where(id: target).first
    context_program = Program.find(program_id)
    users = []
    unless targetting.role == "pitch"
      if targetting.role == "all"
        users = User.or(:"_participant".in=> [context_program.id.to_s]).or(:"_mentor".in=> [context_program.id.to_s]).or(:"_selector".in=> [context_program.id.to_s]).or(:"_panellist".in=> [context_program.id.to_s]).flatten.uniq.map(&:id).map(&:to_s)
      elsif targetting.role == "Innovators"
        users = User.in(:"_participant"=> [context_program.id.to_s]).nin(:id => context_program.pitches.map(&:user_id).flatten.uniq).map(&:id).map(&:to_s)
      else
        users = User.in("_#{targetting.role}" =>  context_program.id.to_s).map(&:id).map(&:to_s)
      end
      if targetting.project_phase_achived.present?
        pitches = context_program.workflows.where(:code => targetting.project_phase_achived).present? ? context_program.workflows.where(:code => targetting.project_phase_achived).first.pitch_phases.map(&:pitch).uniq : nil
        if pitches.present?
          pitch_users = pitches.map(&:mentors).flatten.uniq
          pitch_users << pitches.map(&:members).flatten.uniq
          pitch_users << pitches.map(&:collaboraters).flatten.uniq
          pitch_users << pitches.map(&:user_id)
          users = users & (pitch_users.flatten.uniq.map(&:to_s))
        else
          users = []
        end
      end
      if targetting.project_phase_not_achived.present?
        pitches = context_program.workflows.where(:code => targetting.project_phase_not_achived).present? ? context_program.workflows.where(:code => targetting.project_phase_not_achived).first.pitch_phases.map(&:pitch).uniq : nil
        if pitches.present?
          pitch_users = pitches.map(&:mentors).flatten.uniq
          pitch_users << pitches.map(&:members).flatten.uniq
          pitch_users << pitches.map(&:collaboraters).flatten.uniq
          pitch_users << pitches.map(&:user_id)
          not_required = users & (pitch_users.flatten.uniq.map(&:to_s))
          users = users - not_required
        end
      end
      if targetting.last_activity.present? and targetting.last_activity != 0
        time = targetting.last_activity == 1 ? "" : ( targetting.last_activity == 2 ? 2.day : (targetting.last_activity == 3 ? 7.day : (targetting.last_activity == 4 ? 14.day: 1.month)))
        if time.present?
          users = CommunityFeed.where(:created_at => (Time.now - time)..Time.now).in(:created_by => users).map(&:created_by).map(&:id).uniq.map(&:to_s)
        end
      end
      if targetting.role == "participant" and targetting.applicant_filter_code.present?
        filtered_users = User.in("custom_fields.#{targetting.applicant_filter_code}" => targetting.applicant_filter_option).map(&:id).map(&:to_s)
        users = users & filtered_users
      end
      if targetting.joined_team_filter.present?
        new_users = []
        pitches = context_program.pitches
        if targetting.role == "participant"
          joined_members = pitches.map(&:joined_team_members)
          joined_members.map{|hash| hash.map{|k, v| new_users<< k if (v > (Time.now - targetting.joined_team_filter.to_i.week) and hash.present?)}}
        elsif targetting.role == "mentor"
          joined_mentors = pitches.map(&:joined_team_mentors)
          joined_mentors.map{|hash| hash.map{|k, v| new_users<< k if (v > (Time.now - targetting.joined_team_filter.to_i.week) and hash.present?)}}
        end
        users = users & new_users.map(&:to_s)
      end
    else
      pitches = context_program.pitches.map(&:id)
      if targetting.project_phase_achived.present?
        pitches_phase_achived = context_program.workflows.where(:code => targetting.project_phase_achived).present? ? context_program.workflows.where(:code => targetting.project_phase_achived).first.pitch_phases.map(&:pitch_id).uniq : nil
        if pitches_phase_achived.present?
          pitches = pitches & pitches_phase_achived
        else
          pitches = []
        end
      end
      if targetting.project_phase_not_achived.present?
        pitches_phase_not_achived = context_program.workflows.where(:code => targetting.project_phase_not_achived).present? ? context_program.workflows.where(:code => targetting.project_phase_not_achived).first.pitch_phases.map(&:pitch).uniq : nil
        if pitches_phase_not_achived.present?
          pitches = pitches - pitches_phase_not_achived
        end
      end
      if targetting.last_activity.present? and targetting.last_activity != 0
        time = targetting.last_activity == 1 ? "" : ( targetting.last_activity == 2 ? 2.day : (targetting.last_activity == 3 ? 7.day : (targetting.last_activity == 4 ? 14.day: 1.month)))
        if time.present?
          pitches = CommunityFeed.where(:created_at => (Time.now - time)..Time.now).in(:pitch_id => pitches).map(&:pitch_id).uniq
        end
      end
      if targetting.pitch_filter_code.present?
        filtered_pitches = Pitch.in("custom_fields.#{@targetting.pitch_filter_code}" => targetting.pitch_filter_option).map(&:id)
        pitches = pitches & filtered_pitches
      end
      if pitches.present?
        pitches.each do |pitch|
          users << pitch.team
        end
        users = users.flatten.uniq
      end
    end
    return users
  end
  
  def self.create_default_targets(program_id)
    program = Program.find(program_id)
    participant = Semantic.translate(program, "role_type:participant")
    project = Semantic.translate(program, "pitch")

    #target all users in a program
    Targetting.find_or_create_by(role: "all",  is_default: true, program_id: program_id).update_attributes( name: "All", explaination: "Everyone on the platform")
    #target all Innovators in a program
    Targetting.find_or_create_by(role: "Innovators", is_default: true, program_id: program_id).update_attributes(name: "Innovators", explaination: "All #{participant} without a #{project}")

  end

end
