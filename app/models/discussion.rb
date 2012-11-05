# encoding: utf-8

class Discussion < Exchange

  has_many   :discussion_relationships, :dependent => :destroy
  belongs_to :category, :counter_cache => true

  validates_presence_of :category_id

  # Flag for trusted status, which will update after save if it has been changed.
  attr_accessor :update_trusted

  validate do |discussion|
    discussion.trusted = discussion.category.trusted if discussion.category
  end

  before_update do |discussion|
    discussion.update_trusted = true if discussion.trusted_changed?
  end

  # Set trusted status on all posts and relationships on save
  after_save do |discussion|
    if discussion.update_trusted
      discussion.posts.update_all(:trusted => discussion.trusted?)
      discussion.discussion_relationships.update_all(:trusted => discussion.trusted?)
    end
  end

  class << self
    # Counts total discussion for a user
    def count_for(user)
      if user && user.trusted?
        self.count
      else
        self.where(:trusted => false).count
      end
    end

    # Searches exchanges
    #
    # === Parameters
    # * :query    - The query string
    # * :page     - Page number, starting on 1 (default: first page)
    # * :limit    - Number of posts per page (default: 20)
    # * :trusted  - Boolean, get trusted posts as well (default: false)
    def search_paginated(options={})
      page  = (options[:page] || 1).to_i
      page = 1 if page < 1

      search = self.search do
        fulltext options[:query]
        with     :trusted, false unless options[:trusted]
        order_by :last_post_at, :desc
        paginate :page => page, :per_page => options[:limit] || Exchange::DISCUSSIONS_PER_PAGE
      end

      Pagination.apply(
        search.results,
        Pagination::Paginater.new(
          :total_count => search.total,
          :page        => page,
          :per_page    => options[:limit] || Exchange::DISCUSSIONS_PER_PAGE
        )
      )
    end

    # Find paginated exchanges, sorted by activity, with the sticky ones on top
    #
    # === Parameters
    # * :page     - Page number, starting on 1 (default: first page)
    # * :limit    - Number of posts per page (default: 20)
    # * :category - Only get exchanges in this category
    # * :trusted  - Boolean, get trusted posts as well (default: false)
    def find_paginated(options={})
      conditions = {}
      conditions[:category_id] = options[:category].id if options[:category]
      conditions[:trusted]     = false unless options[:trusted]

      # Utilize the counter cache on category if possible, if not do the query.
      exchanges_count   = options[:category].discussions_count if options[:category]
      exchanges_count ||= Discussion.count(:conditions => conditions)

      Pagination.paginate(
        :total_count => exchanges_count,
        :per_page    => options[:limit] || Exchange::DISCUSSIONS_PER_PAGE,
        :page        => options[:page]  || 1
      ) do |pagination|
        Discussion.find(
          :all,
          :conditions => conditions,
          :limit      => pagination.limit,
          :offset     => pagination.offset,
          :order      => 'sticky DESC, last_post_at DESC',
          :include    => [:poster, :last_poster, :category]
        )
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
        :per_page    => options[:limit] || Exchange::DISCUSSIONS_PER_PAGE,
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

  # Returns true if the user can view this discussion
  def viewable_by?(user)
    if self.trusted?
      (user && user.trusted?) ? true : false
    else
      (Sugar.public_browsing? || user) ? true : false
    end
  end

  # Returns true if the user can edit this discussion
  def editable_by?(user)
    (user && (user.moderator? || user == self.poster)) ? true : false
  end

  # Returns true if the user can post in this discussion
  def postable_by?(user)
    (user && (user.moderator? || !self.closed?)) ? true : false
  end

end
