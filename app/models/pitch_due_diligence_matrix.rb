class PitchDueDiligenceMatrix
  include Mongoid::Document
  include Mongoid::Timestamps

  include App::Workflows::DueDiligenceHook

  belongs_to :pitch
  belongs_to :panellist, :class_name => "User"
  belongs_to :program
  # belongs_to :due_diligence_matrix
  belongs_to :matrix

  field :points,    :type => Integer, :default => 0
  field :feedback,              :type => String, default: ""

  validates :points, :presence => true, :numericality => true

  scope :for_panellist, lambda{|panel| where(:panellist_id => panel)}
  # scope :for_due_diligence_matrix, lambda{|ddm| where(
    # :due_diligence_matrix_id => ddm)}
  scope :for_matrix, lambda{|matrix| where(
    :matrix_id => matrix)}
  after_save :update_pitch_rating
  
  private
  
  def update_pitch_rating
    pitch_overall_points = pitch.pitch_due_diligence_matrices.sum(&:points)
    if matrix.try(:due_diligence_matrix).try(:star_system)
      panel_members = pitch.pitch_due_diligence_matrices.map(&:panellist_id).uniq.count
      panel_votes = pitch.pitch_due_diligence_matrices.where(:points.ne => 0).map(&:panellist_id).count
      overall_score = (pitch_overall_points.to_f)/panel_votes.to_f rescue pitch_overall_points
      pitch.update_attribute(:rating, overall_score)
      matrices_score = pitch.pitch_due_diligence_matrices.where(matrix_id: matrix_id).sum(&:points)
      pitch_matrix_rate = matrices_score.to_f/panel_members.to_f rescue matrices_score
      matrix_rating = pitch.pitch_ratings.find_or_initialize_by(matrix_id: matrix_id)
      matrix_rating[:rating] = pitch_matrix_rate
      matrix_rating.save!
    else
      pitch.update_attribute(:points, pitch_overall_points)
      matrices_score = pitch.pitch_due_diligence_matrices.where(matrix_id: matrix_id).sum(&:points)
      matrix_rating = pitch.pitch_ratings.find_or_initialize_by(matrix_id: matrix_id)
      matrix_rating[:points] = matrices_score
      matrix_rating.save!
    end
  end

end