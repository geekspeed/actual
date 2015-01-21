class CustomReportOrder
  include Mongoid::Document
  include Mongoid::Timestamps

  field :order, :type => Array
  
  belongs_to :custom_report

end