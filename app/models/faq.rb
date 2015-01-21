class Faq

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :organisation
  belongs_to :program
  
  field :question,:type => String
  field :answer,  :type => String 
  mount_uploader :attachment, AttachmentUploader
  field :link,   :type => String
  field :tags,   :type => Array 

  field :role_code, :type => String
  field :relevant_page, :type => String, :default => "summary_page"
  scope :have_tags, lambda{|tag| where(:tags.in => [tag])}
  #validates :question, :answer, :presence => true


end
