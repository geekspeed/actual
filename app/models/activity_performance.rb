class ActivityPerformance
  include Mongoid::Document
  include Mongoid::Timestamps
  field :status, type: Boolean, default: false  
  field :video_watch_duration, type: String, default: ""
  field :video_watch_status, type: Boolean, default: false  
  belongs_to :user
  belongs_to :module_activity
  belongs_to :pitch
  has_many :activity_notes
end