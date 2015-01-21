class HelpContent
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program
  belongs_to :custom_field,  :class_name => "App::CustomFields::Models::CustomField"

  field :field_name,      :type => String
  field :content,         :type => String
  field :text_for,        :type => String
  
  scope :for_custom_field, lambda{|custom_field| where(:custom_field_id => custom_field) unless custom_field.blank? }

end