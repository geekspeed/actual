class PitchCollaboratorRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :request_text, :type => String

  belongs_to :user
  belongs_to :pitch

  validates_uniqueness_of :pitch_id, :scope => :user_id

end