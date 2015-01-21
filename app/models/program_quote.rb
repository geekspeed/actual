class ProgramQuote
  include Mongoid::Document
  include Mongoid::Timestamps
  
  mount_uploader :avatar, AvatarUploader
  
  field :name, :type => String
  field :organisation_name, :type => String
  field :content , :type => String

  belongs_to :program_summary
end
