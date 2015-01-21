class BadgeAuthority
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :organisation
  has_many :app_badges

  field :name, type: String
  field :url, type: String
  field :description, type: String
  field :email, type: String

  validates :name, :presence => true
  validates :url, :presence => true

  mount_uploader :image, AvatarUploader

end