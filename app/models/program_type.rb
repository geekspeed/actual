class ProgramType
  include Mongoid::Document
  include Mongoid::Timestamps

  before_create :assign_code

  # attr_protected :code

  field :title,                   :type => String
  field :program,                 :type => Boolean, :default => false
  field :all_applicants_accepted, :type => Boolean, :default => false
  field :some_applicants_accepted,:type => Boolean, :default => false
  field :code,                    :type => String,  :default => ""

  def to_s
    title
  end

  def applicable_phases
    case code
      when "collaborative_innovation_program", "accelerator_+_application_filtering"
        [:pre_application_phase, :application_phase, :shortlist_phase, :winner_selection_phase, :program_phase, :closed]
      when "incubator", "accelerator_phase_only", "mentoring_program"
        [:pre_application_phase, :application_phase, :program_phase, :closed]
      when "competition/challange"
        [:pre_application_phase, :application_phase, :shortlist_phase, :winner_selection_phase, :closed]
      else
        [:pre_application_phase, :application_phase, :shortlist_phase, :winner_selection_phase, :program_phase, :closed]
    end
  end
  # ["competition/challange", "mentoring_program"]

  private

  def assign_code
    title.gsub(" ", "_").underscore
  end
end
