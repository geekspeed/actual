class CustomReportElement
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :custom_report
  TYPE = ["Text", "Graph", "Table", "Field"]

  field :type, type: String
  field :option, type: String

end