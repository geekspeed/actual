class DueDiligenceMatrix
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program

  field :star_system,           :type => Boolean, default: true
  field :term_for_points,       :type => String
  field :matrix_enable,  :type => Boolean, :default => true
  has_many :matrices, :dependent => :destroy
  accepts_nested_attributes_for :matrices, :reject_if => :all_blank
  
  
  def self.to_csv(program)
    judges = User.in("_panellist" => program.id.to_s)
    pitch_due_diligence_matrices = PitchDueDiligenceMatrix.where(:program_id => program.id).order_by(:created_at => "ASC")
    matrices = pitch_due_diligence_matrices.uniq{|p| p.matrix_id}.map(&:matrix)
    heading = ["Project", "Judge", matrices.map(&:description)]
    matrices.each_with_index{|m, i| heading << "#{m.description} Comment"}
    heading.flatten!
    CSV.generate do |csv|
      csv << heading
      index = 0
      program.pitches.each do |pitch|
        row = []
        pitch_matrices = pitch_due_diligence_matrices.where(:pitch_id => pitch.id).order_by(:created_at => "ASC")
        pitch_matrices.map(&:panellist).uniq.each do |judge|
          index += 1
          star = program.try(:due_diligence_matrix).try(:star_system)
          calculate = star ? :rating : :points
          if pitch[calculate] > 0
            current_matrices = pitch_matrices.where(:panellist_id => judge.id)
            points = current_matrices.map(&:points)
            (matrices.count-points.count).times{points << 0} if (matrices.count-points.count) > 0
            row = [pitch.title, judge.full_name, points, current_matrices.map(&:feedback)]
            csv << row.flatten
          else
            row = []
            row = [pitch.title, judge.full_name]
            matrices.each{|m| row << 0}
            csv << row
          end
        end
      end
    end
  end

  private

  def self.total_score(pitch, program)
    star = program.try(:due_diligence_matrix).try(:star_system)
    star ? pitch.rating.round(2) : pitch.points
  end
end
