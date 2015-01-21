class EcoPlan
  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :attachment, AttachmentUploader

  #INDEXES
  index({ location: 1 }, {  background: true })

  field :date,      :type => Date
  field :time_from, :type => String
  field :time_to,   :type => String
  field :activity,  :type => String
  field :location,  :type => String

  belongs_to :eco_summary
  
  default_scope ascending('date')
end
