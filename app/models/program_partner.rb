class ProgramPartner
  include Mongoid::Document
  include Mongoid::Timestamps
  
  mount_uploader :logo, AvatarUploader
  mount_uploader :document, AttachmentUploader
  field :website,  :type => String

  belongs_to :program_summary
end
