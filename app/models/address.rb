class Address
  include Mongoid::Document
  include Mongoid::Timestamps

  field :line_1,                  :type => String
  field :line_2,                  :type => String
  field :city,                    :type => String
  field :zipcode,                 :type => String
  field :state,                   :type => String
  field :country,                 :type => String

  embeds_one :telephone
  accepts_nested_attributes_for :telephone
  
  belongs_to :organisation

  #INDEXES
  index({ country: 1, state: 1, zipcode: 1 }, { background: true })
end
