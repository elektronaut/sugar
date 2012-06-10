# encoding: utf-8

require 'pagination'

# = Exchange
#
# Exchange is the base class for all threads, which both Discussion and Conversation inherit from.
#
# == Pagination
#
# The *_paginated methods returns a collection decorated with pagination info,
# see the Pagination module for more information.

class Exchange < ActiveRecord::Base

  set_table_name 'discussions'

  # Default number of discussions per page
  DISCUSSIONS_PER_PAGE = 30

  # These attributes should be filtered from params
  UNSAFE_ATTRIBUTES = :id, :sticky, :user_id, :last_poster_id, :posts_count, :created_at, :last_post_at, :trusted

  # Virtual attribute for the body of the first post
  attr_accessor :body

  # Skips validation of @body if true
  attr_accessor :skip_body_validation

  # User which is updating the exchange, required for closing exchanges
  attr_accessor :updated_by

  belongs_to :poster,           :class_name => 'User', :counter_cache => :discussions_count
  belongs_to :closer,           :class_name => 'User'
  belongs_to :last_poster,      :class_name => 'User'
  has_many   :posts,            :order => ['created_at ASC'], :dependent => :destroy, :foreign_key => 'discussion_id'
  has_one    :first_post,       :class_name => 'Post',   :order => ['created_at ASC'], :foreign_key => 'discussion_id'
  has_many   :discussion_views, :dependent => :destroy, :foreign_key => 'discussion_id'

  validates_presence_of :title
  validates_length_of   :title, :maximum => 100, :too_long => 'is too long'
  validates_presence_of :body, :on => :create, :unless => :skip_body_validation

  validate do |exchange|
    # Validate and handle closing of discussions
    if exchange.closed_changed?
      if !exchange.closed? && (!exchange.updated_by || !exchange.closeable_by?(exchange.updated_by))
        exchange.errors.add(:closed, "can't be changed!")
      elsif exchange.closed?
        exchange.closer = exchange.updated_by
      else
        exchange.closer = nil
      end
    end
  end

  after_update do |exchange|
    # Update the first post if @body has been changed
    if exchange.body && !exchange.body.empty? && exchange.body != exchange.posts.first.body
      exchange.posts.first.update_attributes(:body => exchange.body, :edited_at => Time.now)
    end
  end

  # Automatically create the first post
  after_create do |exchange|
    if exchange.body && !exchange.body.empty?
      exchange.posts.create(:user => exchange.poster, :body => exchange.body)
    end
  end

  searchable do
    text    :title
    string  :type
    integer :poster_id
    integer :last_poster_id
    integer :category_id
    boolean :trusted
    boolean :closed
    boolean :sticky
    time    :created_at
    time    :updated_at
    time    :last_post_at
  end

  class << self

    # Sets the state of work safe URLs
    def work_safe_urls=(state)
      @@work_safe_urls = state
    end

    # Gets the state of work safe URLs
    def work_safe_urls
      @@work_safe_urls ||= false
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
        paginate :page => page, :per_page => DISCUSSIONS_PER_PAGE
      end

      Pagination.apply(
        search.results,
        Pagination::Paginater.new(
          :total_count => search.total,
          :page        => page,
          :per_page    => DISCUSSIONS_PER_PAGE
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
        :per_page    => options[:limit] || DISCUSSIONS_PER_PAGE,
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

    # Deletes attributes which normal users shouldn't be able to touch from a param hash
    def safe_attributes(params)
      safe_params = params.dup
      Exchange::UNSAFE_ATTRIBUTES.each do |r|
        safe_params.delete(r)
      end
      return safe_params
    end

    # Counts total discussion for a user
    def count_for(user)
      if user && user.trusted?
        Discussion.count(:all)
      else
        Discussion.count(:all, :conditions => {:trusted => false})
      end
    end

  end

  # Finds paginated posts. See <tt>Post.find_paginated</tt> for more info.
  def paginated_posts(options={})
    Post.find_paginated({:discussion => self}.merge(options))
  end

  # Finds posts created since offset
  def posts_since_index(offset)
    Post.find(:all,
      :conditions => ['discussion_id = ?', self.id],
      :order      => 'created_at ASC',
      :limit      => 200,
      :offset     => offset.to_i,
      :include    => [:user]
    )
  end

  # Finds the number of the last page
  def last_page(per_page=Post::POSTS_PER_PAGE)
    (self.posts_count.to_f/per_page).ceil
  end

  # Detects and fixes discrepancies in the counter cache
  def fix_counter_cache!
    if posts_count != posts.count
      logger.warn "counter_cache error detected on Exchange ##{self.id}"
      Exchange.update_counters(self.id, :posts_count => (posts.count - posts_count) )
    end
  end

  # Does this exchange have any labels?
  def labels?
    (self.closed? || self.sticky? || self.nsfw? || self.trusted?) ? true : false
  end

  # Returns an array of labels (for use in the thread title)
  def labels
    labels = []
    labels << "Trusted" if self.trusted?
    labels << "Sticky"  if self.sticky?
    labels << "Closed"  if self.closed?
    labels << "NSFW"    if self.nsfw?
    return labels
  end

  # Humanized ID for URLs
  def to_param
    slug = self.title
    slug = slug.gsub(/[\[\{]/,'(')
    slug = slug.gsub(/[\]\}]/,')')
    slug = slug.gsub(/[^\w\d!$&'()*,;=\-]+/,'-').gsub(/[\-]{2,}/,'-').gsub(/(^\-|\-$)/,'')
    (self.class.work_safe_urls) ? self.id.to_s : "#{self.id.to_s};" + slug
  end

  if ENV['RAILS_ENV'] == 'test'
    def posts_count
      self.posts.count
    end
  end

end