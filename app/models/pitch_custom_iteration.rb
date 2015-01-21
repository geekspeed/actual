class PitchCustomIteration
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :pitch
  belongs_to :program
  belongs_to :user

  field :custom_field_id, :type => String, :default => ""
  field :content, :type => String, :default => ""
  
  #scopes
  scope :iteration_for, lambda{|custom_field_id| where(:custom_field_id => custom_field_id.to_s)}

end