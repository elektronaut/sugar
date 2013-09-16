class PasswordResetToken < ActiveRecord::Base
  belongs_to :user
  before_create :ensure_token
  before_create :ensure_expiration

  validates :user_id, presence: true

  DEFAULT_EXPIRATION = 48.hours

  scope :active,  -> { where("expires_at >= ?", Time.now) }
  scope :expired, -> { where("expires_at < ?", Time.now) }

  class << self
    def expire!
      self.expired.delete_all
    end

    def find_by_token(token)
      self.active.where(token: token).first
    end
  end

  def expired?
    self.expires_at < Time.now
  end

  private

  def ensure_expiration
    self.expires_at ||= Time.now + DEFAULT_EXPIRATION
  end

  def ensure_token
    self.token ||= SecureRandom.hex(16)
  end
end
