class ContextMessage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :context_message,  :type => String,  :default => ""
  field :anchor,  :type => String,  :default => ""

  belongs_to :program
  
end
