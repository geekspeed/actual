class VisitedFaqProgram
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program
  belongs_to :user

  field :pages_visited,         :type => Array, :default => []

end