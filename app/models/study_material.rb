class StudyMaterial
  include Mongoid::Document
  include Mongoid::Timestamps
  field :resource_description, type: String
  field :resource_format, type: String
  field :link, type: String
  mount_uploader :attachment, AttachmentUploader
  belongs_to :module_activity
end
