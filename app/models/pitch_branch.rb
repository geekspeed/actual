class PitchBranch
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program
  has_many :pitches

  field :branch_name, :type => String, :default => ""

end