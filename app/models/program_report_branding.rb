class ProgramReportBranding
  include Mongoid::Document
  include Mongoid::Timestamps

  field :header, type: String
  field :signature, type: String
  field :footer, type: String

  belongs_to :program
end
