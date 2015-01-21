module App
  module CustomFields
    module Models

      class CustomField
        include Mongoid::Document
        include Mongoid::Timestamps

        before_create :build_code
        before_save :build_options, :build_phases

        belongs_to :program
        has_many :upload_file,                 :class_name => "App::CustomFields::Models::UploadFile", :dependent => :destroy

        TYPE = ["text", "text_area", "dropdown","dropdown_with_other", "dropdown_with_multiple_select", "date", "video_url", "image_url", "branch_field", "website", "sound_url",
                 "gallery", "file_upload", "text_section"]
        field :label,         :type => String
        field :code,          :type => String
        field :element_type,  :type => String
        field :placeholder,   :type => String
        field :required,      :type => Boolean, :default => false
        field :use_as_filter, :type => Boolean, :default => false
        field :for_class,     :type => String
        field :disabled,      :type => Boolean, :default => false
        field :private_to_team, :type => Boolean, :default => false
        #anchor will differetiate between two forms in same class
        #e.g user about form is different for mentor and applicant
        field :anchor,        :type => String
        field :options,       :type => Array, :default => []
        field :linked,        :type => String,:default => ""
        field :phases,        :type => Array, :default => []
        field :position,      :type => String
        field :sequence,      :type => Integer
        field :parent_id,     :type => String, :default => ""
        field :parent_option, :type => String, :default => ""
        field :text_section_content, :type => String
        #field :parent_id,     :type => Integer

        scope :for_program, lambda{|program| where(:program_id => program)}
        scope :for_class, lambda{|klass| where(:for_class => klass)}
        scope :for_anchor, lambda{|anchor| where(:anchor => anchor)}
        scope :enabled, where(:disabled => false)

        validates :label, :element_type, :for_class, :presence => true
        validates :element_type, inclusion: { in: TYPE }
        validates :label, exclusion: { in: %w(test Test) }

        scope :filters, where(use_as_filter: true)

        default_scope order_by(:sequence => :asc, :created_at=> :asc)

        def formatted_options
          read_attribute(:options).join(",")
        end

        private

        def build_code
          self.code = (label.gsub(/[^0-9A-Za-z]/, ' ').gsub(/\s+/,'_').downcase + id.to_s)
        end

        def build_options
          if options.is_a?(String)
            if (element_type == "dropdown_with_other" && !options.split(",").collect(&:strip).include?("Other") && options.split(",").collect(&:strip).size != 0)
              self.options = options.split(",").collect(&:strip).append("Other")
            else
              self.options = options.split(",").collect(&:strip)
            end
          end
        end

        def build_phases
          if self[:phases] == "all"
            phases = program.workflows.map(&:code)
            self.phases = phases
          else
            self.phases = [self["phases"]].flatten
          end
        end

      end
    end
  end
end