class BadgeRule
  include Mongoid::Document
  include Mongoid::Timestamps

  Collection = {"Events" => "events","Project"=> "project", "Buzzfeed" => "buzzfeed", "Manual" => "manual"}
  
  Events = {"Signup" =>"Signup", "Attend" => "Attend", "Provide Feedback" => "Provide Feedback"}
  Project = {"Feedback" => "Feedback", "Post in project feed" => "Post in project feed", "Upload txt document" => "Upload txt document", "Upload document image" => "Upload document image"}
  Buzzfeed = {"Post in buzz feed" => "Post in buzz feed" }
  Manual = {}

  belongs_to :app_badge
  belongs_to :program

  field :criteria_description,   type: String, default: ""
  field :criteria,               type: String, default: ""
  field :sub_criteria,           type: String
  field :instances,              type: Integer, default: 5
  field :expiry,                 type: String, default: "never"
  field :expiry_date,            type: Date
  field :expiry_day,             type: Integer, default: 30
  field :event_session_id,       type: String
  field :program_event_id,       type: String, default: ""
  
  validates_uniqueness_of :sub_criteria, :scope => [:program_id, :program_event_id, :event_session_id]
end