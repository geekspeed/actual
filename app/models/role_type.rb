class RoleType
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :name
  before_create :set_code, :set_default_name

  field :default_name,  :type => String
  field :name,          :type => String
  field :code,          :type => String

  validate :name, :presence => true, :uniqueness => true

  def to_s
    name
  end

  def set_code
    self.code = name.underscore.gsub(" ", "_")
  end

  def set_default_name
    self.default_name = name
  end

  def self.public_sign_up
    RoleType.in(:code => ["participant", "mentor"])
  end

  def self.on_programs
    all.to_a - [universal, on_organisation].flatten.compact
  end

  def self.on_organisation
    [find_by(code: "company_admin"), find_by(code: "program_admin"), find_by(code: "ecosystem_member")]
  end

  def self.on_company
    [find_by(code: "company_admin")]
  end

  def self.on_programs_semantics(program)
    roles = all.to_a - [universal, on_organisation].flatten.compact + on_company.flatten.compact
    semantic_role = []
    roles.each do |role|
      role_name = "role_type:#{role.name.parameterize('_')}"
      role_type = Semantic.t(program, role_name, "s")
      role.name = role_type
      semantic_role << role
    end
    semantic_role
  end

  def self.universal
    [find_by(code: "super_admin")]
  end

  private

  def self.seeds!
    find_or_create_by(:name => "Super Admin")
    find_or_create_by(:name => "Company Admin")
    find_or_create_by(:name => "Program Admin")
    find_or_create_by(:name => "Participant")
    find_or_create_by(:name => "Mentor")
    find_or_create_by(:name => "Panellist")
    find_or_create_by(:name => "Selector")
    find_or_create_by(:name => "Ecosystem Member")
    find_or_create_by(:name => "Awaiting Participant")
    find_or_create_by(:name => "Awaiting Mentor")
  end

end
