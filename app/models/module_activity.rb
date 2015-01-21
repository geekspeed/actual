class ModuleActivity
  include Mongoid::Document
  include Mongoid::Timestamps

  after_save :video_to_thumbnail

  field :title, type: String
  field :time_taken, type: String
  field :deadline, type: Date
  field :deadline_option, :type => Boolean, :default => false
  field :description, type: String
  field :greater_detail, type: String
  field :resource_format, type: String
  field :link, type: String
  field :action, type: String
  field :keywords, type: Array, default: []
  field :video_thumbnail, type: String
  field :position, type: Integer
  mount_uploader :attachment, AttachmentUploader
  belongs_to :course_module
  has_many :study_materials, :dependent => :destroy
  has_many :activity_project_fields, :dependent => :destroy
  has_many :activity_performances, :dependent => :destroy
  accepts_nested_attributes_for :study_materials, reject_if: :all_blank
  accepts_nested_attributes_for :activity_project_fields, reject_if: :all_blank

  default_scope asc(:position)

  def video_to_thumbnail
    vimeo_http = self.link.match(/http:\/\/(?:www.)?(vimeo).com\/(?:watch\?v=)?(.*?)(?:\z|&)/) 
    vimeo_https = self.link.match(/https:\/\/(?:www.)?(vimeo).com\/(?:watch\?v=)?(.*?)(?:\z|&)/)
    provider = !vimeo_http.blank? ? vimeo_http : vimeo_https
    if !provider.blank? && provider[1] == "vimeo"
      self.video_thumbnail = JSON.parse(open("http://vimeo.com/api/oembed.json?url=#{provider[0]}").read)["thumbnail_url"]
      self.touch
    end
  end

end