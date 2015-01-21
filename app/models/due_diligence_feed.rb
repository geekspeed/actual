class DueDiligenceFeed
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :activities, :type => Array, :default => []
  belongs_to :pitch
  belongs_to :panellist, :class_name => "User"
  
end