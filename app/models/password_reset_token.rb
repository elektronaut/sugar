class PasswordResetToken < ActiveRecord::Base
  belongs_to :user
  before_create :ensure_token
  before_create :ensure_expiration

  validates :user_id, presence: true

  DEFAULT_EXPIRATION = 48.hours

  scope :active,  -> { where("expires_at >= ?", Time.now.utc) }
  scope :expired, -> { where("expires_at < ?", Time.now.utc) }

  class << self
    def expire!
      expired.delete_all
    end

    def find_by_token(token)
      active.find_by(token: token)
    end
  end

  def expired?
    expires_at < Time.now.utc
  end

  private

  def ensure_expiration
    self.expires_at ||= Time.now.utc + DEFAULT_EXPIRATION
  end

  def ensure_token
    self.token ||= SecureRandom.hex(16)
  end
end
