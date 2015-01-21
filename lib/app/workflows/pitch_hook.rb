require 'active_support/concern'
module App
  module Workflows

    module PitchHook
      extend ActiveSupport::Concern

      included do
        has_many :complete_phases, class_name: "PitchPhase", 
          dependent: :destroy
        after_create :draft!
        before_save :shall_close_project!
      end

      def shall_close_project!
        if self.changed.include?("closed") && self.closed?
          close_project!
        end
      end

      def draft!
        draft = workflows.find_by code: "draft_pitch"
        draft.complete!(self, user_id)
      end

      def publish!(user = nil)
        user ||= user_id
        publish = workflows.find_by code: "publish_pitch"
        publish.complete!(self, user)
      end

      def close_mentors!(user = nil)
        user ||= user_id
        phase = workflows.find_by code: "close_application_for_new_mentors"
        phase.complete!(self, user)
      end

      def found_mentors!(user = nil)
        user ||= user_id
        phase = workflows.find_by code: "find_mentors"
        phase.complete!(self, user)
      end

      def close_project!(user = nil)
        user ||= user_id
        phase = workflows.find_by code: "close_project"
        phase.complete!(self, user)
      end

      def draft?
        workflow = workflows.find_by code: "draft_pitch"
        complete?(workflow)
      end

      def published?
        workflow = workflows.find_by code: "publish_pitch"
        complete?(workflow)
      end

      def close_mentors?
        workflow = workflows.find_by code: "close_application_for_new_mentors"
        complete?(workflow)
      end

      def complete?(workflow)
        workflow.complete?(self)
      end
    end

    module DueDiligenceHook
      extend ActiveSupport::Concern

      included do
        after_create :due_diligence!
      end

      def due_diligence!
        workflow = program.workflows.find_by code: 
        "due_diligence"
        workflow.complete!(pitch, panellist)
      end

    end

  end
end