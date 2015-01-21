class Telephone
  include Mongoid::Document
  include Mongoid::Timestamps

  field :country_code,      :type => String
  field :number,            :type => String

  embedded_in :address

  def to_s
    "#{country_code}-#{number}"
  end
end
