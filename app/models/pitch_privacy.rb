class PitchPrivacy
  include Mongoid::Document
  include Mongoid::Timestamps

  field :private, :type => Boolean, default: false
  field :custom_field_id, :type => String

  belongs_to :pitch
  scope :for_custom_field, lambda{|c_field| where(:custom_field_id => c_field.id.to_s)}

end
