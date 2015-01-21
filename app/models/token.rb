class Token
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :event_session

  before_create :generate_digest

  field :digest, :type => String
  field :star, :type => Integer
  field :expires_at, :type => DateTime

  def self.create_active_tokens(event_session, user_id)
    Token.expire_all_tokens(event_session, user_id)
    (1..5).each do |i|
      event_session.tokens.create(user_id: user_id, star: i)
    end
  end

  def expired?
    Time.now > expires_at if expires_at
  end

  def generate_digest
    begin
      self[:digest] = SecureRandom.urlsafe_base64(32)
    end while Token.where(:digest => self[:digest]).present?
  end

  def self.expire_all_tokens(event_session, user_id)
    event_session.tokens.where(user_id: user_id).each do |t|
      t.touch :expires_at
    end
  end

end