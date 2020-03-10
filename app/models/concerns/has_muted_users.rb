module HasMutedUsers
  extend ActiveSupport::Concern

  included do
    has_many :user_mutes, dependent: :destroy
  end

  def muted?(user, exchange: nil)
    user_mutes.where(exchange: exchange, muted_user: user).any?
  end

  def mute!(user, exchange: nil)
    user_mutes.create(muted_user: user,
                      exchange: exchange)
  end

  def unmute!(user, exchange: nil)
    user_mutes.where(muted_user: user,
                     exchange: exchange).destroy_all
  end
end
