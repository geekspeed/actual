class QuestionOrder
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :order, :type => Array

  belongs_to :survey
end
