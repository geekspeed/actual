class PitchIteam
  include Mongoid::Document
  include Mongoid::Timestamps

  field :iteration,         :type => Integer
  field :content,           :type => String

end
