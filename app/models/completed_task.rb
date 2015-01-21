class CompletedTask
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :task
  belongs_to :user
  field :completed,   :type => Boolean
  field :date,        :type => Date
end