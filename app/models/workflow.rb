class Workflow
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_protected :active

  belongs_to :program
  has_many :pitch_phases
  has_one :workflow_milestone

  field :phase_name,      type: String,   default: ""
  field :applicable_role, type: String,   default: ""
  field :tracking,        type: String,   default: "Status Button"
  field :help_text,       type: String,   default: ""
  field :target_url,       type: String,   default: ""
  field :phase_conditions,   type: Array, default: []
  field :position,        type: Integer,  default: 0
  field :on,              type: Boolean,  default: false
  field :hardcode,        type: Boolean,  default: false
  field :active,          type: Boolean,  default: false
  field :undoable,        type: Boolean,  default: false
  field :code,            type: String,   default: ""
  field :multiple,        type: Boolean,  default: false
  field :change_role,        type: Boolean,  default: true

  before_create :assign_code

  validates :phase_name, :applicable_role, :position,
   presence: true
  validates_uniqueness_of :phase_name, scope: :program_id

  default_scope asc(:position)
  scope :on, where(on: true)
  scope :role_specific, lambda{|applicable_role| where(:applicable_role => applicable_role) if applicable_role != "company_admin"}

  def pitches_achieved
    program.pitches.in(id: pitch_phases.collect(&:pitch_id))
  end

  def pitches_not_achieved
    program.pitches.not_in(id: 
      pitch_phases.collect(&:pitch_id))
  end

  def toggle!
    update_attribute(:active, !active)
  end

  def complete!(for_pitch, by_user)
    if multiple?
      pitch_phases.find_or_create_by(program_id: 
        program_id, pitch: for_pitch, completed_by: by_user)
    else
      pitch_phases.create!(program_id: program_id, pitch: 
        for_pitch, completed_by: by_user)
    end
  end

  def complete?(for_pitch, by_user = nil)
    entry = pitch_phases.where(pitch: for_pitch) #.count.zero?
    entry.where(completed_by: by_user) if multiple?
    !entry.count.zero?
  end

  def phase_for(for_pitch, by_user = nil)
    entry = pitch_phases.where(pitch: for_pitch)
    entry.where(completed_by: by_user) if multiple?
    entry
  end

  def self.default_workflow_for(program)

    first = create!(phase_name: "Draft Pitch", program: program,
      applicable_role: "participant", tracking: "System",
      help_text: "N/A as this is first", on: true,
      position: -99, hardcode: true, active: true )

    first.toggle!

    create!(phase_name: "Publish Pitch", program: program,
      applicable_role: "participant", tracking: "Status
      Button", help_text: "It will publish pitch", on: true,
      position: 1, undoable: true )

    create!(phase_name: "Find Mentors", program: program,
      applicable_role: "participant", tracking: "Status
      Button", help_text: "It will take to the mentor page",
      on: false, position: 2 )

    create!(phase_name: "Close application for new mentors", program: program,
      applicable_role: "participant", tracking: "Status
      Button", help_text: "It will close application for new mentors",
      on: false, position: 3, undoable: true )

    create!(phase_name: "Agree scope with mentors", program: program,
      applicable_role: "participant", tracking: "Status
      Button", help_text: "Agreed scope with mentors",
      on: false, position: 4, undoable: true )

    create!(phase_name: "Start project", program: program,
      applicable_role: "participant", tracking: "Status
      Button", help_text: "Mark project as started",
      on: false, position: 5, undoable: true )

    create!(phase_name: "Rate a person", program: program,
      applicable_role: "participant", tracking: "Status
      Button", help_text: "Start rating people.",
      on: false, position: 5, undoable: true )

    create!(phase_name: "Submission deadline", program: program,
      applicable_role: "company_admin", tracking: "System",
       help_text: "Stops editing of entries",
      on: false, position: 7, change_role: false )

    create!(phase_name: "Project Submission", program: program,
      applicable_role: "participant", tracking: "Status
      Button", help_text: "Project Submission",
      on: false, position: 6, undoable: true )

    create!(phase_name: "Due Diligence", program: program,
      applicable_role: "panellist", tracking: "Status
      Button", help_text: "", on: true,
      position: 8, multiple: true )

    create!(phase_name: "Shortlisting", program: program,
      applicable_role: "selector", tracking: "System",
      help_text: "Mark it as a shortlisted", on: true,
      position: 9, undoable: true, multiple: true )

    create!(phase_name: "Winner Selection", program: program,
      applicable_role: "selector", tracking: "System",
      help_text: "Mark it as a winner", on: true,
      position: 10, undoable: true, multiple: true )

    create!(phase_name: "Case Study", program: program,
      applicable_role: "participant", tracking: "Status
      Button", help_text: "Provide a case study about 
        your project",
      on: false, position: 11 )

    create!(phase_name: "Close Project", program: program,
      applicable_role: "participant", tracking: "Status
      Button", help_text: "Will close this project",
      on: false, position: 12, undoable: true )

    create!(phase_name: "Close Program", program: program,
      applicable_role: "company_admin", tracking: "System",
      help_text: "Close the program", on: true,
      position: 9999, hardcode: true )
  end

  private

  def assign_code
    self.code = phase_name.gsub(/[^0-9A-Za-z]/, ' ').gsub(/\s+/,'_').downcase
  end
end