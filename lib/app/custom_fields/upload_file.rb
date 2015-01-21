module App
  module CustomFields
    module Models
      
      
      class UploadFile
        include Mongoid::Document
        include Mongoid::Timestamps
        mount_uploader :avatar, ::AvatarUploader
        
        field :for_class,     :type => String
        field :class_id,     :type => String
        
        belongs_to :custom_field, :class_name => "App::CustomFields::Models::CustomField"
        scope :for_custom_field, lambda{|custom_field| where(:custom_field_id => custom_field.id)}
        scope :for_class, lambda{|klass| where(:for_class => klass)}
      end
      
    end
  end
end
