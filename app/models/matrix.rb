class Matrix
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :due_diligence_matrix

  field :description,         :type => String,  :default => ""
  field :one_star,            :type => String,  :default => ""
  field :five_star,           :type => String,  :default => ""
  field :max_points,          :type => Integer, :default => ""
  field :order_no,            :type => Integer, :default => ""

  validate :description, :presence => true
  validate :max_points, :numeric => true
  default_scope ascending('order_no')
  
end
