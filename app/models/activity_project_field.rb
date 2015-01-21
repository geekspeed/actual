class ActivityProjectField
  include Mongoid::Document
  include Mongoid::Timestamps
  field :custom_field_id, type: String
  belongs_to :module_activity
end