module App
  module Cloner
    class Base

      attr_accessor :organisation, :program, :master_program,
        :settings

      def initialize(organisation_id, program_id)
        @master_program = Program.master_for(organisation_id).first
        @settings = MasterSetting.for(@master_program).first
        @program = Program.find(program_id)
        @organisation = Organisation.find(organisation_id)
      end

      def clone!
        return false if @master_program.blank?
        return false if @program.master_program?
        clone_matrix!
        clone_semantics!
        clone_workflow!
        clone_messages!
        clone_participants_form!
        clone_mentors_form!
        clone_pitch_form!
      end

      def clone_matrix!
        if @settings and @settings.matrix_cloneable?
          @program.due_diligence_matrix = @master_program.due_diligence_matrix.clone
          if @program.due_diligence_matrix.save
            matrix = @program.due_diligence_matrix
            matrix.matrices = @master_program.due_diligence_matrix.matrices.clone
          end
        end
      end

      def clone_semantics!
        if @settings and @settings.semantic_cloneable?
          Semantic.for_program(@master_program).each do |semantic|
            clone = semantic.clone
            clone.program = @program
            clone.save
          end
        end
      end

      def clone_workflow!
        if @settings and @settings.workflow_cloneable?
          @program.workflows = @master_program.workflows.clone
        else
          Workflow.default_workflow_for(@program)
        end
      end

      def clone_messages!
        if @settings and @settings.messages_cloneable?
          @program.customize_admin_emails = @master_program.customize_admin_emails.clone
        end
      end

      def clone_participants_form!
        if @settings and @settings.participant_form_cloneable?
          cf = App::CustomFields::Models::CustomField
              .for_program(@master_program).for_anchor("participant")
          cf.each do |field|
            clone = field.clone
            clone.program = @program
            clone.save
          end
        end
      end

      def clone_mentors_form!
        if @settings and @settings.mentor_form_cloneable?
          cf = App::CustomFields::Models::CustomField
              .for_program(@master_program).for_anchor("mentor")
          cf.each do |field|
            clone = field.clone
            clone.program = @program
            clone.save
          end
        end
      end

      def clone_pitch_form!
        if @settings and @settings.pitch_form_cloneable?
          cf = App::CustomFields::Models::CustomField
              .for_program(@master_program).for_anchor("pitch")
          cf.each do |field|
            clone = field.clone
            clone.program = @program
            clone.save
          end
        end
      end
    end
  end
end