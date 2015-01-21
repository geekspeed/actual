class BasicFieldToggle
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :program

  field :upload,         :type => Boolean, :default => true
  field :bio,            :type => Boolean, :default => true
  field :speciality,     :type => Boolean, :default => true
  field :skills,         :type => Boolean, :default => true
  field :interests,      :type => Boolean, :default => true
  field :qualifications, :type => Boolean, :default => true
  field :profile,        :type => Boolean, :default => true
  field :user_type,      :type => String

end