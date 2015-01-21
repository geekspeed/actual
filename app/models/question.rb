class Question
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :survey
  belongs_to :user
  has_one :answer
  
  before_save :build_answer_options, :strip_parent_option

  field :question_text,      type: String
  field :question_type,      type: String
  field :answer_options,     type: Array
  field :parent_id,          type: String, default: ""
  field :parent_option,      type: String, default: ""
  field :required,           type: Boolean, default: false

  QUESTIONTYPE = ["text", "text_area", "dropdown", "dropdown_with_multiple_select", "date", "video_url", "image_url", "branch_field"]
  
  def linked
    ""
  end

  def code
    self.id
  end

  private
  
  def build_answer_options
    if (question_type == "dropdown" or question_type=="dropdown_with_other" or
       question_type == "dropdown_with_multiple_select" or question_type == "branch_field")
      self[:answer_options] = self[:answer_options].split(",").collect(&:strip)
    end
  end

  def strip_parent_option
    unless parent_id.blank?
      self[:parent_option] = self[:parent_option].strip
    end
  end

end
