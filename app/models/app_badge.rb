class AppBadge
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program
  belongs_to :badge_authority
  has_many :user_badges, dependent: :destroy
  has_one :badge_rule, :dependent => :destroy
  has_one :badge_desc, :dependent => :destroy

  field :name,                   type: String, default: ""
  field :description,            type: String, default: ""
  field :badge_type,             type: String, default: "internal"
  field :tags,                   type: Array,  default: []
  mount_uploader :image, AvatarUploader

  validates :name, :presence => true
  validates :image, :presence => true

  accepts_nested_attributes_for :badge_rule, reject_if: :all_blank
end 
