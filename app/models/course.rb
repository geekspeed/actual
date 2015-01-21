class Course
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :intro, type: String
  field :link, type: String

  belongs_to :program
  has_many :course_modules, :dependent => :destroy
end
