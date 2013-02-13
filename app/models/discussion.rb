# encoding: utf-8

class Discussion < Exchange
  include SearchableExchange, Viewable

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
    # Counts total discussion for a user
    def count_for(user)
      if user && user.trusted?
        self.count
      else
        self.where(:trusted => false).count
      end
    end

    # Finds popular discussions within a defined time range, sorted by popularity.
    # The collection is decorated with the Pagination module, which provides pagination info.
    # Takes the following options:
    # * :page     - Page number, starting on 1 (default: first page)
    # * :since    - Since time
    # * :limit    - Number of posts per page (default: 20)
    # * :trusted  - Boolean, get trusted posts as well
    def find_popular(options={})
      options = {
        :since => 7.days.ago
      }.merge(options)

      conditions = [
        'posts.discussion_id = discussions.id AND posts.created_at > ?',
        options[:since]
      ]

      # Ignore trusted posts unless requested
      unless options[:trusted]
        conditions = [
          ['discussions.trusted = ?', conditions.shift].compact.join(' AND '),
          false
        ] + conditions
      end

      if options[:trusted]
        discussions_count = Discussion.count_by_sql([
          'SELECT COUNT(DISTINCT discussion_id) ' +
          'FROM posts, discussions ' +
          'WHERE posts.discussion_id = discussions.id ' +
          'AND posts.created_at > ? AND discussions.type = ?',
          options[:since],
          'Discussion'
        ])
      else
        discussions_count = Discussion.count_by_sql([
          'SELECT COUNT(DISTINCT discussion_id) ' +
          'FROM posts, discussions ' +
          'WHERE posts.discussion_id = discussions.id ' +
          'AND posts.created_at > ? AND discussions.type = ? AND discussions.trusted = ?',
          options[:since],
          'Discussion',
          false
        ])
      end

      Pagination.paginate(
        :total_count => discussions_count,
        :per_page    => options[:limit] || self.per_page,
        :page        => options[:page]  || 1
      ) do |pagination|
        discussions = Discussion.find(
          :all,
          :select     => 'discussions.*, COUNT(posts.id) AS recent_posts_count',
          :from       => 'discussions, posts',
          :conditions => conditions,
          :group      => 'discussions.id',
          :limit      => pagination.limit,
          :offset     => pagination.offset,
          :order      => 'recent_posts_count DESC'
        )
      end
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
