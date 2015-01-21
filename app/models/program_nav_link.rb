class ProgramNavLink
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url,            :type => String
  field :name,           :type => String
  field :custom_url,     :type => Boolean, default: false
  field :order,          :type => Integer

  belongs_to :program

  validates_uniqueness_of :url, scope: [:program_id], message: "You can add a url only once."
 
end
