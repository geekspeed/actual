module DueDiligencesHelper
  
  def pitch_rating(pitch, judge)
    pitch_ratings = PitchDueDiligenceMatrix.where(:panellist_id => judge.id, :program_id => @program.id, :pitch_id => pitch.id)
    ratings = pitch_ratings.map(&:points)
    sum = ratings.sum
    star = @program.try(:due_diligence_matrix).try(:star_system)
    calculate = star ? :rating : :points
    pitch[calculate] > 0 ? sum : 0
  end

  def total_score(pitch)
    star = @program.try(:due_diligence_matrix).try(:star_system)
    star ? pitch.rating.round(2) : pitch.points.to_i
  end
end
