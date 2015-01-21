require 'active_support/concern'
module App
  module CustomFields
    module Base
      extend ActiveSupport::Concern

      included do
        field :custom_fields,   :type => Hash, :default => {}
        before_save :check_for_badges
        after_create :check_for_award
      end

      module ClassMethods
        def custom_fields
          App::CustomFields::Models::CustomField.for_class(self.to_s)
        end

        def custom_fields_with_anchor(anchor)
          custom_fields.for_anchor(anchor)
        end

        def label_for(code)
          custom_fields.where(:code => code).limit(1).first
        end

        def values_for_linked(code, value_for)
          result = {}
          scoped.each do |cf|
            if cf['custom_fields'] and cf['custom_fields'][code].present?
              key = "#{code}_#{cf['custom_fields'][code].downcase unless cf['custom_fields'][code].is_a? Array}"
              if cf["custom_fields"][value_for].present? || result[key].blank?
                result[key] = cf["custom_fields"][value_for]
              end
            end
          end
          result
        end

        def auto_complete_values(custom_field)
          ne(:"custom_fields.#{custom_field}" => nil)
          .collect(&:custom_fields).map{|a| a[custom_field.to_s]}
        end
      end

      # Define on self, since it's  a class method
      def method_missing(method_sym, *arguments, &block)
        labels = self.class.custom_fields.collect(&:code)
        if labels.include? method_sym.to_s
          self.custom_fields[method_sym.to_s]
        elsif labels.include? method_sym.to_s.gsub("=", "")
          self.custom_fields[method_sym.to_s.gsub("=", "")] = arguments.first
        else
          super
        end
      end
      
      private
      
      def check_for_award
        obj_class = self.class.to_s
        case obj_class
          when "PitchFeedback"
            self.check_for_achievement
          when "CommunityFeed"
            self.check_for_achievement
          when "EventRating"
            self.check_for_achievement
          when "PitchDocument"
            self.check_for_achievement
          when "EventRecord"
            self.check_for_signup_badge
          when "CustomEvent"
            self.check_for_achievement
        end
      end
      def check_for_badges
        obj_class = self.class.to_s
        case obj_class
          when "EventRecord"
            self.check_for_achievement
        end
      end
    end
  end
end