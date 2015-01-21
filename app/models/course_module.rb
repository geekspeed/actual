class CourseModule
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :description, type: String
  field :greater_detail, type: String
  field :resource_format, type: String
  field :link, type: String
  field :keywords, type: Array, default: []
  mount_uploader :attachment, AttachmentUploader
  belongs_to :course
  has_many :module_activities, :dependent => :destroy
  default_scope asc(:created_at)
end
