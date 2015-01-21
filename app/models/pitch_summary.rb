class PitchSummary < PitchIteam

  belongs_to :pitch, :inverse_of => :summary
  after_save :reindex_pitches
  before_destroy :reindex_pitches
  # history tracking all Summary documents
  # note: tracking will not work until #track_history is invoked
  include Mongoid::History::Trackable

  # telling Mongoid::History how you want to track changes
  track_history   :on => [:content]
  
  private
  def reindex_pitches
    if self.changed?
      Resque.enqueue(App::Background::SolrIndexing, self.pitch.class.to_s, self.pitch.id)
    end
  end
end