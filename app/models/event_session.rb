class EventSession
  include Mongoid::Document
  
  belongs_to :program_event
  
  field :location,  :type => String
  field :seat_no,  :type => Integer
  field :date,      :type => Date
  field :time_from, :type => String
  field :time_to,   :type => String
  field :description, :type => String, default: ""
  field :date_to,   :type => Date
  
  has_many :event_records, :dependent => :destroy
  has_many :event_ratings, :as => :identity, :dependent => :destroy
  has_many :tokens, :dependent => :destroy
  default_scope ascending('date')

  def self.to_pdf(event_session)
    wicked = WickedPdf.new


        # Make a PDF in memory
        pdf_file = wicked.pdf_from_string( 
            ActionController::Base.new().render_to_string(
                :template   => 'event_sessions/event_record.pdf.erb',
                :layout     => 'layouts/pdf.html.erb',
                :locals     => { 
                    :event_session => event_session
                    
                } 
            ),
            :pdf => 'event_sessions/event_record.pdf.erb',
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
                        :program => event_session.program_event.program

                        
                    },
                )
              }, 
            :footer => {
                    :content => ActionController::Base.new().render_to_string(
                    :template   => 'layouts/pdf/footer.html.erb',                
                    :layout     => 'layouts/pdf.html.erb',
                    :locals     => { 
                        :program => event_session.program_event.program
                        
                    },
                )
              }
  
            
        )


    file_name = "#{UUIDTools::UUID.timestamp_create.to_s}.pdf"
    File.open("#{Rails.root.to_s}/tmp/#{file_name}", "wb") do |f|
      f.write(pdf_file)
      f.close()
    end
    File.chmod(0755,"#{Rails.root.to_s}/tmp/#{file_name}")
    file_name
  end

  def self.to_csv(event_records)
    CSV.generate do |csv|
      csv << ["Sno.", "Last Name", "First Name", "Project","Registration Date", "Presence"]
      index = 0
      event_records.each do |record|
        user = record.try(:user)
        pitches = []
        pitches << record.try(:program).try(:pitches).where(:user_id =>record.user.id)
        pitches << record.try(:program).try(:pitches).where(:members => record.user.id.to_s) 
        pitch_title = pitches.try(:flatten).try(:first).try(:title)
        presence = record.try(:confirmed_at).nil? ? "No" : "Yes"
        index += 1
        csv << [index, user.last_name, user.first_name, pitch_title, record.created_at.try(:app_format), presence] if user
      end
    end
  end

end