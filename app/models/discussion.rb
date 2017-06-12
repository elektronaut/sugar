# encoding: utf-8

class Discussion < Exchange
  class InvalidExchange < StandardError; end

  include SearchableExchange
  include Viewable

  has_many :discussion_relationships, dependent: :destroy

  scope :for_view, -> { sorted.with_posters }

  before_save :trusted_will_change
  after_save :update_trusted_status

  class << self
    def popular_in_the_last(days = 7.days)
      joins(:posts)
        .where("posts.created_at > ?", days.ago)
        .group("exchanges.id")
        .order("COUNT(posts.id) DESC")
    end
  end

  # Converts a discussion to a conversation
  def convert_to_conversation!
    raise InvalidExchange unless valid?
    transaction do
      update_attributes(type: "Conversation")
      becomes(Conversation).tap do |conversation|
        conversation.unlabel!
        posts.update_all(conversation: true, trusted: false)
        participants.each { |p| conversation.add_participant(p) }
        discussion_relationships.destroy_all
      end
    end
  end

  def participants
    User.find_by_sql(
      "SELECT u.*, MAX(p.created_at) AS last_post_at " \
      "FROM users u, posts p " \
      "WHERE p.exchange_id = #{id} AND p.user_id = u.id " \
      "GROUP BY u.id "
    )
  end

  def editable_by?(user)
    return false unless user
    return true if user.moderator?
    moderators.include?(user)
  end

  def postable_by?(user)
    (user && (user.moderator? || !closed?)) ? true : false
  end

  private

  def trusted_will_change
    @trusted_will_change = trusted_changed?
  end

  def update_trusted_status
    return unless @trusted_will_change
    posts.update_all(trusted: trusted?)
    discussion_relationships.update_all(trusted: trusted?)
    participants.each do |user|
      user.update_column(
        :public_posts_count,
        user.discussion_posts.where(trusted: false).count
      )
    end
  end
end
