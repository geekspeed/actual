class CustomReport 
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program
  belongs_to :creator, class_name: "User"

  field :name, type: String
  field :type, type: String

  TYPE = ["Program", "Project", "Participant"]

  has_many :custom_report_elements, :dependent => :destroy
  accepts_nested_attributes_for :custom_report_elements, reject_if: :all_blank

  has_one :custom_report_order, :dependent => :destroy
  accepts_nested_attributes_for :custom_report_order, reject_if: :all_blank

  def self.chart_data(report_data, graph_type, program, organisation)
    filter = ProgramReport.report_fetch(report_data, program, organisation)
    if graph_type=="Line Chart" 
      ProgramReport.filter_line_data(filter) 
    elsif graph_type=="Pie Chart"
      ProgramReport.filter_pie_data(filter)
    end
  end

  def self.chart_table(report_data, graph_type, program, organisation)
    filter = ProgramReport.report_fetch(report_data, program, organisation)
    if graph_type=="Line Chart" 
      return filter[0]
    elsif graph_type=="Pie Chart"
      return ProgramReport.filter_pie_data(filter)[0] 
    end
  end

  def self.get_elements(type, program)
    case type
    when "Project"
      program.pitches
    when "Participant"
      User.in(:"_participant" => program.id.to_s)
    else
      context_program
    end
  end
  def self.get_section_title(object)
    case object.class
    when "User".constantize
      object.full_name
    when "Pitch".constantize
      object.title
    end
  end

  def self.generate_individual_report(custom_report, program, organisation, pitch)
        wicked = WickedPdf.new
        # Make a PDF in memory
        pdf_file = wicked.pdf_from_string( 
            ActionController::Base.new().render_to_string(
                :template   => 'custom_reports/individual_pdf.html.erb',
                :layout     => 'layouts/pdf.html.erb',
                :locals     => { 
                    :report => custom_report,
                    :program => program,
                    :organisation => organisation,
                    :pitch => pitch

                }
                
            ),
            :pdf => 'custom_reports/individual_pdf.html.erb',
            :layout => 'pdf.html.erb',
              :margin => {
                :top      => '1.0in',
                :bottom   => '1.8in',
                :left     => '0.1in',
                :right    => '0.1in'
            },
            :header => {
                    :content => ActionController::Base.new().render_to_string(
                    :template   => 'layouts/pdf/header.html.erb',
                    :layout     => 'layouts/pdf.html.erb',
                    :locals     => { 
                        :program => program
                        
                    },
                )
              }, 
            :footer => {
                    :content => ActionController::Base.new().render_to_string(
                    :template   => 'layouts/pdf/footer_without_signature.html.erb',
                    :layout     => 'layouts/pdf.html.erb',
                    :locals     => { 
                        :program => program
                        
                    },
                )
              }
        )

        file_name = "#{custom_report.name.parameterize("_")}.pdf"
        FileUtils.mkdir_p("#{Rails.root.to_s}/tmp")
        File.open("#{Rails.root.to_s}/tmp/#{file_name}", "wb") do |f|
          f.write(pdf_file)
          f.close()
        end
        File.chmod(0755,"#{Rails.root.to_s}/tmp/#{file_name}")
        file_name
      end
  
  def self.generate_individual_report_participant(custom_report, program, organisation, pitch)
    users = User.in(id: pitch.team).in(:"_participant" => pitch.program_id.to_s)
        wicked = WickedPdf.new
        # Make a PDF in memory
        pdf_file = wicked.pdf_from_string( 
            ActionController::Base.new().render_to_string(
                :template   => 'custom_reports/individual_pdf_participants.html.erb',
                :layout     => 'layouts/pdf.html.erb',
                :locals     => { 
                    :report => custom_report,
                    :program => program,
                    :organisation => organisation,
                    :users => users

                }
                
            ),
            :pdf => 'custom_reports/individual_pdf.html.erb',
            :layout => 'pdf.html.erb',
              :margin => {
                :top      => '1.0in',
                :bottom   => '1.8in',
                :left     => '0.1in',
                :right    => '0.1in'
            },
            :header => {
                    :content => ActionController::Base.new().render_to_string(
                    :template   => 'layouts/pdf/header.html.erb',
                    :layout     => 'layouts/pdf.html.erb',
                    :locals     => { 
                        :program => program
                        
                    },
                )
              }, 
            :footer => {
                    :content => ActionController::Base.new().render_to_string(
                    :template   => 'layouts/pdf/footer_without_signature.html.erb',
                    :layout     => 'layouts/pdf.html.erb',
                    :locals     => { 
                        :program => program
                        
                    },
                )
              }
        )

        file_name = "#{custom_report.name.parameterize("_")}.pdf"
        FileUtils.mkdir_p("#{Rails.root.to_s}/tmp")
        File.open("#{Rails.root.to_s}/tmp/#{file_name}", "wb") do |f|
          f.write(pdf_file)
          f.close()
        end
        File.chmod(0755,"#{Rails.root.to_s}/tmp/#{file_name}")
        file_name
      end

end