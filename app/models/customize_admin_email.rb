class CustomizeAdminEmail
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program
  belongs_to :user
  field :email_name, :type => String
  field :subject, :type => String
  field :description, :type => String
  field :from, :type => String
  field :to, :type => String
  field :role_type, :type => String
end
