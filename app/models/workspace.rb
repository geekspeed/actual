class Workspace
  include Mongoid::Document
  include Mongoid::Timestamps
 

  field :left_buzz,                 type: String,   default: ""
  field :left_milestone,            type: String,   default: ""
  field :left_feedback,             type: Boolean,  default: false
  field :left_contacts,             type: Boolean,  default: false
  field :left_survey,               type: Boolean,  default: false
  field :left_team,                 type: Boolean,  default: false
  field :left_to_do_list,           type: Boolean,  default: false
  field :right_workflow,            type: Boolean,  default: true
  field :right_team,                type: Boolean,  default: true
  field :right_skills_needed,       type: Boolean,  default: true  
  field :left_event,                type: String,   default: ""
  field :todo_list_help,            type: String,   default: ""
  field :to_do_list_join_this_team, type: Boolean,  default: true
  field :to_do_list_join_this_team_txt, type: String,   default: ""
  field :hide_events_tab,           type: Boolean,   default: true
  
  

  belongs_to :program

  def self.workspace_sementic(sementic_attr,static_name, program)
    workspace = program.try(:workspace)
    !workspace.try(sementic_attr).blank? ? workspace.try(sementic_attr) : static_name
  end

end
