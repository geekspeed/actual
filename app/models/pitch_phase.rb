class PitchPhase
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program
  belongs_to :workflow
  belongs_to :pitch

  belongs_to :completed_by, class_name: "User"

end
