class ProgramSummaryOrder
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :order, :type => Array

  belongs_to :program_summary
end
