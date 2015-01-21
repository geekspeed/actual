class Ecosystem
  include Mongoid::Document
  include Mongoid::Timestamps

  before_create :generate_code

  field :name,            :type => String
  field :description,     :type => String
  field :location,        :type => String
  field :market,          :type => String
  field :code,            :type => String

  has_many :programs

  validates :name, :presence => true, :uniqueness => true

  def generate_code
    self.code = name.downcase.gsub(" ", "_")
  end

  def to_param
    code
  end

  def to_s
    name
  end
end
