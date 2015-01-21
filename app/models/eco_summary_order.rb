class EcoSummaryOrder
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :order, :type => Array

  belongs_to :eco_summary
end
