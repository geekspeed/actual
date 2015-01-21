class BadgeDesc
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :app_badge

  field :url,   type: String
end