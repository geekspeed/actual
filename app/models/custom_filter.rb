class CustomFilter
  include Mongoid::Document
  include Mongoid::Timestamps

  field :rule_type, :type => String, :default => "none"
  field :is_private, :type => Boolean, :default => false
  field :ankor, :type => String
  belongs_to :program

  has_many :custom_rules, :dependent => :destroy
  
  accepts_nested_attributes_for :custom_rules, reject_if: :all_blank
  
end
