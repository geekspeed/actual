class DueDiligencePost
  include Mongoid::Document
  include Mongoid::Timestamps

  include App::Workflows::DueDiligenceHook

  belongs_to :pitch
  belongs_to :panellist, :class_name => "User"
  belongs_to :program
  # belongs_to :due_diligence_matrix
  belongs_to :matrix

  field :points,    :type => Integer, :default => 0
  field :feedback,  :type => String, default: ""
end