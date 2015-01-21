class PitchRating
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :pitch
  belongs_to :pitch_due_diligence_matrix, :foreign_key => :matrix_id

  field :rating, :type => Float, :default => 0
  field :points, :type => Float, :default => 0

end