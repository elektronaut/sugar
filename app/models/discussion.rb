# encoding: utf-8

class Discussion < Exchange
  include SearchableExchange
  include Viewable

  has_many   :discussion_relationships, :dependent => :destroy
  belongs_to :category, :counter_cache => true

  validates_presence_of :category_id

  # Flag for trusted status, which will update after save if it has been changed.
  attr_accessor :update_trusted

  scope :with_category, includes(:poster, :last_poster, :category)
  scope :for_view,      sorted.with_posters.with_category

  validate      :inherit_trusted_from_category
  before_update :set_update_trusted_flag
  after_save    :update_trusted_status

  class << self
    # Scopes discussions popular in the last n days
    def popular_in_the_last(days=7.days)
      select('discussions.*, COUNT(posts.id) AS recent_posts_count')
        .joins(:posts)
        .where('posts.created_at > ?', days.ago)
        .group('discussions.id')
        .order('recent_posts_count DESC')
    end
  end

  def participants
    User.find_by_sql(
      "SELECT u.*, MAX(p.created_at) AS last_post_at " +
      "FROM users u, posts p " +
      "WHERE p.discussion_id = #{self.id} AND p.user_id = u.id " +
      "GROUP BY u.id "
    )
  end

  # Returns true if the user can edit this discussion
  def editable_by?(user)
    (user && (user.moderator? || user == self.poster)) ? true : false
  end

  # Returns true if the user can post in this discussion
  def postable_by?(user)
    (user && (user.moderator? || !self.closed?)) ? true : false
  end

  private

  def inherit_trusted_from_category
    self.trusted = self.category.trusted if self.category
    true
  end

  def set_update_trusted_flag
    self.update_trusted = true if self.trusted_changed?
    true
  end

  # Set trusted status on all posts and relationships on save
  def update_trusted_status
    if self.update_trusted
      self.posts.update_all(:trusted => self.trusted?)
      self.discussion_relationships.update_all(:trusted => self.trusted?)
    end
  end

end
