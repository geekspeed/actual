class Reporting
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program

  field :graph_name,      :type => String
  field :metric_name,	  :type => String
  field :dashboard,	  :type => Boolean, :default => false
  field :reporting,      :type => Array
  field :graph_type,      :type => String
  def self.generate_report(custom_report, program, organisation)
        wicked = WickedPdf.new
        # Make a PDF in memory
        pdf_file = wicked.pdf_from_string( 
            ActionController::Base.new().render_to_string(
                :template   => 'custom_reports/preview1.html.erb',
                :layout     => 'layouts/pdf.html.erb',
                :locals     => { 
                    :report => custom_report,
                    :program => program,
                    :organisation => organisation

                }
                
            ),
            :pdf => 'custom_reports/preview1.html.erb',
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

        file_name = "#report_#{custom_report.id}.pdf"
        FileUtils.mkdir_p("#{Rails.root.to_s}/tmp")
        File.open("#{Rails.root.to_s}/tmp/#{file_name}", "wb") do |f|
          f.write(pdf_file)
          f.close()
        end
        File.chmod(0755,"#{Rails.root.to_s}/tmp/#{file_name}")
        file_name
      end
      
end
