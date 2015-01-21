class Milestone
  include Mongoid::Document
  include Mongoid::Timestamps

  field :achieved,        :type => Boolean,   :default => false
  field :description,     :type => String

  has_many :tasks, :dependent => :destroy
  belongs_to :pitch
  belongs_to :user


  validates :description, presence: true

  def achieved!
    update_attribute(:achieved, true)
  end
end
