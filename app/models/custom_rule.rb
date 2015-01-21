class CustomRule
  include Mongoid::Document
  include Mongoid::Timestamps

  after_save :delete_empty
  
  belongs_to :custom_filter
  
  field :title, :type => String
  field :role, :type => String
  field :event_for, :type => String 
  field :field_name, :type => String
  field :field_value, :type => String
  
  def delete_empty
    unless field_value.present? and event_for.present? and field_name.present?
      self.delete
    end
  end
end
