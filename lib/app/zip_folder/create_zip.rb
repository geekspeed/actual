module App
  module ZipFolder
    class CreateZip
    
    require 'rubygems'
    require 'zip'
    require 'mime/types'
    
    def self.create_zip_pdf(folder, pitch_id, prog_id, option)
      # cmd = "tar -czvf #{Rails.root.to_s}/tmp/#{folder} #{Rails.root.to_s}/tmp/#{folder}"
      # `#{cmd}`
       # return folder
      # zipfile_name = "#{Rails.root.to_s}/tmp/#{user_id}.zip"
      # Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        # input_filenames.each do |filename|
          # # Two arguments:
          # # - The name of the file as it will appear in the archive
          # # - The original file, including the path to find it
          # #zipfile.mkdir(zipfile_name) unless File.exists?("#{zipfile_name}")
          # zipfile.add( "#{filename}", "#{zipfile_name}")
          # #File.delete("#{Rails.root.to_s}/tmp/#{filename}")
        # end
        # zipfile_name
      # end
      program = Program.where(id: prog_id ).first
      case option
        when "all"
          all_pitches = program.pitches
        when "submit_phase"
          all_pitches = program.pitched_completed_phase("project_submission") 
        when "current"
          all_pitches = Pitch.where(id: pitch_id)
      end
      main = "#{Rails.root.to_s}/tmp/"
      directory = "#{Rails.root.to_s}/tmp/#{folder}/"
      zipfile_name = "#{Rails.root.to_s}/tmp/#{folder}.zip"
      
      Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        Dir[File.join(directory, '**', '**')].each do |file|
          zipfile.add(file.sub(directory, ''), file)
        end
        # Dir[File.join(main, '*.docx')].each do |file|
          # zipfile.add(file.sub(main, ''), file)
        # end
        all_pitches.each do |pitch|
          pitch.documents.each_with_index do |document, i|
            begin
              filename = document.attachment.file.filename.split('.')[0]
              extension = MIME::Types[document.attachment.content_type].first.extensions.first
              zipfile.add("#{pitch.title.gsub('/', '').gsub('|', '')}_attachment_#{i}_#{filename}.#{extension}", document.attachment.path)
            rescue Exception => e
              next
            end
          end
        end
      end
      FileUtils.rm_rf(Dir.glob("#{Rails.root.to_s}/tmp/#{folder}/"))
      
    end
    
    end
  end
end