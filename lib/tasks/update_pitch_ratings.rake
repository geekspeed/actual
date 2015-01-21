namespace :patch do
  desc "[FIX] Update ratings for existing pitches"
  task :update_pitch_ratings => :environment do
    Pitch.all.each do |pitch|
      pitch_overall_points = pitch.pitch_due_diligence_matrices.sum(&:points)
      if pitch.program.try(:due_diligence_matrix).try(:star_system)
        panel_members = pitch.pitch_due_diligence_matrices.map(&:panellist_id).uniq.count
        panel_votes = pitch.pitch_due_diligence_matrices.where(:points.ne => 0).map(&:panellist_id).count
        overall_score = (pitch_overall_points.to_f)/panel_votes.to_f rescue pitch_overall_points
        pitch.update_attribute(:rating, overall_score.nan? ? 0.0 : overall_score)
        pitch.pitch_due_diligence_matrices.each do |due_diligence|
          matrices_score = pitch.pitch_due_diligence_matrices.where(matrix_id: due_diligence.matrix_id).sum(&:points)
          pitch_matrix_rate = matrices_score.to_f/panel_members.to_f rescue matrices_score
          matrix_rating = pitch.pitch_ratings.find_or_initialize_by(matrix_id: due_diligence.matrix_id)
          matrix_rating[:rating] = pitch_matrix_rate
          matrix_rating.save!
        end
      else
        pitch.update_attribute(:points, pitch_overall_points)
        pitch.pitch_due_diligence_matrices.each do |due_diligence|
          matrices_score = pitch.pitch_due_diligence_matrices.where(matrix_id: due_diligence.matrix_id).sum(&:points)
          matrix_rating = pitch.pitch_ratings.find_or_initialize_by(matrix_id: due_diligence.matrix_id)
          matrix_rating[:points] = matrices_score
          matrix_rating.save!
        end
      end
    end
  end
end