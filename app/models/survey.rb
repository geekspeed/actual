class Survey
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :questions, :dependent => :destroy
  has_one :question_order, :dependent => :destroy
  has_many :answers, :dependent => :destroy

  accepts_nested_attributes_for :questions, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :question_order, reject_if: :all_blank

  belongs_to :user
  belongs_to :program
  belongs_to :organisation

  mount_uploader :avatar, AvatarUploader

  CATEGORIES = ["One-Off", "Recurring"]
  TARGET_AUDIENCE= ["Projects","Participants","Mentors"]

  field :name,                          type: String
  field :category,                      type: String
  field :recurring_period,              type: Integer
  field :end_date,                      type: Date
  field :description,                   type: String
  field :show_results_to_participants,  type: Boolean, default: false
  field :target_audience,               type: String
  field :total_audience,                type: Array, default: []
  field :audience_started_survey,       type: Array, default: []
  field :audience_completed_survey,     type: Array, default: []
  field :time,                          type: Time
  field :recurring_period_update,       type: Time
  field :visibility,                    type: Array, default: []
  field :content,                       type: String, default: ""
  field :subject,                       type: String, default: ""
  
  before_save :audience

  def create_questions questions
    questions.each do |field|
      if field[:question_text].present?
        option_attributes = field.delete("option_fields")
        option_attributes ||= []
        parent_field = save_field(field)
        destroy_dependent_option_fields parent_field
        option_attributes.each do |option_field|
          save_field option_field, parent_field.id
        end
      end
    end if questions
  end

  def audience
    if target_audience_changed?
      case target_audience
        when "Projects"
          audience = User.in(id: program.pitches.map(&:team).flatten).map(&:id)
        when "Participants"
          audience = User.in("_participant" => program.id.to_s).map(&:id)
        when "Mentors"
          audience = User.in("_mentor" => program.id.to_s).map(&:id)
      end
      self[:total_audience] = audience
    end
  end

  def audience_not_completed
    total_audience-audience_completed_survey
  end
  
  def visible? place
    visibility.include? place
  end

  private
  
  def save_field field, parent_field_id = ""
    if field[:id].present?
      cf = questions.find(field[:id])
      cf.update_attributes(field.merge({parent_id: parent_field_id}))
    else
      cf = questions.new(field.merge({parent_id: parent_field_id}))
      cf.save
    end
    return cf
  end

  def destroy_dependent_option_fields parent_field
    questions.where(parent_id: parent_field.id.to_s).delete
  end

end