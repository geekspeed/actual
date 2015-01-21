class ProgramEvent
  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :attachment, AttachmentUploader

  #INDEXES
  index({ location: 1 }, {  background: true })

  field :title,  :type => String
  field :description,  :type => String
  field :is_private,  :type => Boolean

  belongs_to :program
  has_many :event_sessions, :dependent => :destroy
  accepts_nested_attributes_for :event_sessions, reject_if: :all_blank
  
  default_scope ascending('created_at')
end
