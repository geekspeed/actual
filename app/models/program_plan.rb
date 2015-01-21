class ProgramPlan
  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :attachment, AttachmentUploader

  #INDEXES
  index({ location: 1 }, {  background: true })

  field :date,      :type => Date
  field :date_from, :type => Date
  field :time_from, :type => String
  field :time_to,   :type => String
  field :activity,  :type => String
  field :location,  :type => String
  field :eventbrite_id, :type => String
  field :eventbrite_event_url, :type => String
  field :attendees,     :type => Array, :default => []
  field :not_attending, :type => Array, :default => []
  field :user_access_token, type: String

  belongs_to :program_summary
  
  validates_uniqueness_of :eventbrite_id, scope: :program_summary_id, :allow_nil => true
  
  default_scope ascending('date')
  
  def add_to_attendees!(user_id)
    existing_keys = send(:attendees)
    existing_keys << user_id
    update_attribute(:attendees, existing_keys)
  end
  
  def add_to_not_attending!(user_id)
    existing_keys = send(:not_attending)
    existing_keys << user_id
    update_attribute(:not_attending, existing_keys)
  end
  
  def attending?(user_id)
    user_id = user_id.respond_to?(:id) ? user_id.id.to_s : user_id
    attendees.include?(user_id)
  end
  
  def not_attending?(user_id)
    user_id = user_id.respond_to?(:id) ? user_id.id.to_s : user_id
    not_attending.include?(user_id)
  end
  
  def signed_up?(user_id)
    attending?(user_id) or not_attending?(user_id)
  end
  
end
