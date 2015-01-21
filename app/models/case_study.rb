class CaseStudy
  include Mongoid::Document
  include Mongoid::Timestamps
  
  mount_uploader :logo, AvatarUploader
  mount_uploader :document, AttachmentUploader

  belongs_to :program_summary
end
