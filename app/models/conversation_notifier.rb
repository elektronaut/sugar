# encoding: utf-8

class ConversationNotifier
  attr_reader :post, :url

  def initialize(post, url)
    @post, @url = post, url
  end

  def deliver_now
    mailers.each(&:deliver_now)
  end

  def deliver_later
    mailers.each(&:deliver_later)
  end

  private

  def mailer(user)
    Mailer.new_post(
      post.user.username,
      user.email,
      url,
      post.exchange.title
    )
  end

  def mailers
    recipients.map { |r| mailer(r) }
  end

  def notify_relationships
    relationships.where(notifications: true)
  end

  def notify_users
    notify_relationships.
      map(&:user).
      select(&:email?)
  end

  def recipients
    notify_users.reject { |p| p == post.user }
  end

  def relationships
    post.exchange.conversation_relationships.includes(:user)
  end
end
