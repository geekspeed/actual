class UserContactRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :requester, :class_name => "User", :foreign_key => :requester_id
  belongs_to :program

  field :receiver_id,          :type => String
  field :message,              :type => String
  field :subject,              :type => String

end