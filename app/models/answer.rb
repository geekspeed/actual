class Answer
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :question
  belongs_to :survey
  belongs_to :user

  field :answer_text,      type: String

end