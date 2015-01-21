module App
  module Pdf
    class GenrateVotingSheet
      
      def self.generate_files(prog_id, option, pitch_id)
        program = Program.where(id: prog_id ).first
        folder = UUIDTools::UUID.timestamp_create.to_s
        case option
          when "all"
            all_pitches = program.pitches
          when "submit_phase"
            all_pitches = program.pitched_completed_phase("project_submission") 
          when "current"
            all_pitches = Pitch.where(id: pitch_id)
        end
        all_pitches.each do |pitch|
          GenrateVotingSheet.create_voting_copy(pitch, folder) rescue next
        end
        GenrateVotingSheet.create_collaborative_judging_score(all_pitches, folder, program) unless option == "current"
        return folder
      end
      
      
      
      def self.create_voting_copy(pitch, folder)
        wicked = WickedPdf.new
    
        # Make a PDF in memory
        pdf_file = wicked.pdf_from_string( 
            ActionController::Base.new().render_to_string(
                :template   => 'voting_sheets/voting_sheet_genration.pdf.erb',
                :layout     => 'layouts/pdf.html.erb',
                :locals     => { 
                    :pitch => pitch
                    
                } 
            ),
            :pdf => 'voting_sheets/voting_sheet_genration.pdf.erb',
            :layout => 'pdf.html.erb',
              :margin => {
                :top      => '1.3in',
                :bottom   => '1.8in',
                :left     => '0.1in',
                :right    => '0.1in'
            },
            :header => {
                    :content => ActionController::Base.new().render_to_string(
                    :template   => 'layouts/pdf/header.html.erb',                
                    :layout     => 'layouts/pdf.html.erb',
                    :locals     => { 
                        :program => pitch.try(:program)
                        
                    },
                )
              }, 
            :footer => {
                    :content => ActionController::Base.new().render_to_string(
                    :template   => 'layouts/pdf/footer.html.erb',                
                    :layout     => 'layouts/pdf.html.erb',
                    :locals     => { 
                        :program => pitch.try(:program)
                        
                    },
                )
              }
  
            
        )
    
        file_name = "#{pitch.title.gsub('/', '').gsub('|', '')}.pdf"
        FileUtils.mkdir_p("#{Rails.root.to_s}/tmp/#{folder}")
        File.open("#{Rails.root.to_s}/tmp/#{folder}/#{file_name}", "wb") do |f|
          f.write(pdf_file)
          f.close()
        end
        File.chmod(0755,"#{Rails.root.to_s}/tmp/#{folder}/#{file_name}")
        file_name
      end
      
      
      
      
      def self.create_collaborative_judging_score(pitches, folder, program)
        wicked = WickedPdf.new
    
        # Make a PDF in memory
        pdf_file = wicked.pdf_from_string( 
            ActionController::Base.new().render_to_string(
                :template   => 'voting_sheets/judging_scores.pdf.erb',
                :layout     => 'layouts/pdf.html.erb',
                :locals     => { 
                    :pitches => pitches
                    
                } 
            ),
            :pdf => 'voting_sheets/voting_sheet_genration.pdf.erb',
            :layout => 'pdf.html.erb',
              :margin => {
                :top      => '0.5in',
                :bottom   => '0.5in',
                :left     => '0.1in',
                :right    => '0.1in'
            },
            # :header => {
                    # :content => ActionController::Base.new().render_to_string(
                    # :template   => 'layouts/pdf/header.html.erb',                
                    # :layout     => 'layouts/pdf.html.erb',
                    # :locals     => { 
                        # :program => program
#                         
                    # },
                # )
              # }, 
            # :footer => {
                    # :content => ActionController::Base.new().render_to_string(
                    # :template   => 'layouts/pdf/footer.html.erb',                
                    # :layout     => 'layouts/pdf.html.erb',
                    # :locals     => { 
                        # :program => program
#                         
                    # },
                # )
              # }
          
        )
    
        file_name = "all.pdf"
        FileUtils.mkdir_p("#{Rails.root.to_s}/tmp/#{folder}")
        File.open("#{Rails.root.to_s}/tmp/#{folder}/#{file_name}", "wb") do |f|
          f.write(pdf_file)
          f.close()
        end
        File.chmod(0755,"#{Rails.root.to_s}/tmp/#{folder}/#{file_name}")
        file_name
      end
      
    end
  end
end
