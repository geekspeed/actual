class MasterSetting
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program

  scope :for, lambda{|program| where(program_id: program)}

  field :matrix_cloneable,            type: Boolean,    default: false
  field :semantic_cloneable,          type: Boolean,    default: false
  field :workflow_cloneable,          type: Boolean,    default: false
  field :messages_cloneable,          type: Boolean,    default: false
  field :participant_form_cloneable,  type: Boolean,    default: false
  field :mentor_form_cloneable,       type: Boolean,    default: false
  field :pitch_form_cloneable,        type: Boolean,    default: false
end
