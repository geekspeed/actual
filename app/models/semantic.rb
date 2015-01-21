class Semantic
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :program  
  belongs_to :organisation

  field :key,       type: String, default: ""
  field :singular,  type: String, default: ""
  field :plural,    type: String, default: ""
  field :label,     type: String, default: ""
  field :cloneable, type: Boolean, default: false

  index({ program_id: 1 }, { background: true })
  index({ key: 1 }, { background: true })

  validate :key_uniqueness

  scope :for_program, lambda{|program_id| 
    where(program_id: program_id)}
  scope :defaults, where(program_id: 0)
  scope :for_organisation, lambda{|organisation_id| 
    where(organisation_id: organisation_id)}

  before_save :expire_cache!

  alias_method :s,  :singular
  alias_method :p,  :plural

  def self.translate(program, key, verb="singular")
    k = redis_key(program, key)
    cached = fetch!(k, verb)
    return cached if cached.present?
    res = where(program_id: program, key: key).first ||
            where(program_id: 0, key: key).first
    if res
      res.cache!
      ["singular", "s"].include?(verb) ? res.s : res.p
    end
  end

  def self.eco_translate(organisation, key, verb="singular")
    k = redis_key(organisation, key)
    cached = fetch!(k, verb)
    return cached if cached.present?
    res = where(organisation_id: organisation, key: key).first ||
            where(organisation_id: 0, key: key).first
    if res
      res.cache!
      ["singular", "s"].include?(verb) ? res.s : res.p
    end
  end

  def self.translate_for_front_pages(program, key, verb="singular")
    res = where(program_id: program , key: key).first
    if res
      ["singular", "s"].include?(verb) ? res.s : res.p
    end
  end

  class << self
    alias_method :t,  :translate
    alias_method :e,  :eco_translate
    alias_method :tfp,  :translate_for_front_pages
  end

  def cache!
    if defined?($redis)
      $redis.rpush(redis_key, self.s)
      $redis.rpush(redis_key, self.p)
      $redis.expire(redis_key, 12*3600) #12 hours
    end
  end

  def self.fetch!(redis_key, verb)
    if defined?($redis)
      index = ["singular", "s"].include?(verb) ? 0 : 1
      $redis.lindex(redis_key, index)
    end
  end

  def self.redis_key(program, key)
    return nil if program.blank?
    "semantic:#{program.id.to_s}:#{key}"
  end

  def redis_key
    Semantic.redis_key(self.program, self.key)
  end

  def self.create_defaults!
    find_or_create_by(program_id: 0, key: "role_type:participant",
      singular: "Applicant", plural: "Applicants", label: 
      "What's your term for applicants?")
    find_or_create_by(program_id: 0, key: "role_type:mentor",
      singular: "Mentor", plural: "Mentors", label:
      "What's your term for mentors?")
    find_or_create_by(program_id: 0, key: "role_type:panellist",
      singular: "Panel", plural: "Panels", label: 
      "What's your term for panel?")
    find_or_create_by(program_id: 0, key: "role_type:selector",
      singular: "Selector", plural: "Selectors", label: 
      "What's your term for selectors?")
    find_or_create_by(program_id: 0, key: "role_type:company_admin",
      singular: "Company Admin", plural: "Company Admins", label: 
      "What's your term for Company Admins?")
    find_or_create_by(program_id: 0, key: "pitch",
      singular: "Pitch", plural: "Pitches", label: 
      "What's your term for pitches? e.g. New Technologies, 
      Product Concepts, Businness Ideas")
    find_or_create_by(program_id: 0, key: "interest",
      singular: "Interest", plural: "Interests", label: 
      "What's your term for interests? e.g. API's, Mobile Platforms")
    find_or_create_by(program_id: 0, key: "pitch:summary",
      singular: "Summary", plural: "Summaries", label: 
      "What's your term for summary?")
    find_or_create_by(program_id: 0, key: "organisation:name",
      singular: "Programs", plural: "Programs", label: 
      "What's your term for organisation name?")
    find_or_create_by(program_id: 0, key: "program:about_me",
      singular: "About Me", plural: "About Me", label: 
      "What's your term for about me?")
    find_or_create_by(program_id: 0, key: "program:basic",
      singular: "Basics", plural: "Basics", label: 
      "What's your term for basic?")
    find_or_create_by(program_id: 0, key: "program:my_work",
      singular: "My Work", label: "What's your term for My Work?")
    find_or_create_by(program_id: 0, key: "pitch:task",
      singular: "Task", plural: "Tasks", label: 
      "What's your term for tasks?")
  end

  def expire_cache!
    if defined?($redis) && changed?
      $redis.del(redis_key)
    end
  end

  def key_uniqueness
    count = 0
    if !self.program_id.nil?
      count = Semantic.where(program_id: program_id, key: key).count
    elsif !self.organisation_id.nil?
      count = Semantic.where(organisation_id: organisation_id, key: key).count
    end
    if count > 1
      errors.add(:key, "should be unique")
    end
  end

end
