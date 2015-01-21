class ProgramFreeForm
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :section_title, :type => String
  field :sub_title, :type => String
  field :body, :type => String
  field :section_id, :type => String

  belongs_to :program_summary
end
