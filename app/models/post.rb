# encoding: utf-8

require 'post_parser'

class Post < ActiveRecord::Base

  POSTS_PER_PAGE  = 50

  belongs_to :user, :counter_cache => true
  belongs_to :discussion, :class_name => 'Exchange', :counter_cache => :posts_count, :foreign_key => 'discussion_id'
  has_many   :discussion_views

  validates_presence_of :body, :user_id, :discussion_id

  after_create do |post|
    # Automatically update the discussion with last poster info
    post.discussion.update_attributes(:last_poster_id => post.user.id, :last_post_at => post.created_at)
    # Make sure the discussion is marked as participated for the user
    DiscussionRelationship.define(post.user, post.discussion, :participated => true) unless post.conversation?
  end

  attr_accessor :skip_html

  before_save do |post|
    post.edited_at  ||= Time.now
    post.trusted      = post.discussion.trusted if post.discussion
    post.conversation = post.discussion.kind_of?(Conversation)
    post.body_html    = PostParser.new(post.body).to_html unless post.skip_html
  end

  searchable do
    text    :body
    integer :user_id
    integer :discussion_id
    time    :created_at
    time    :updated_at
    boolean :trusted
    boolean :conversation
  end

  class << self

    def find_paginated(options={})
      discussion = options[:discussion]
      Pagination.paginate(
        :total_count => discussion.posts_count,
        :per_page    => options[:limit] || POSTS_PER_PAGE,
        :page        => options[:page] || 1,
        :context     => options[:context] || 0
      ) do |pagination|
        Post.find(
          :all,
          :conditions => ['discussion_id = ?', discussion.id],
          :limit      => pagination.limit,
          :offset     => pagination.offset,
          :order      => 'created_at ASC',
          :include    => [:user]
        )
      end
    end

    def search_paginated(options={})
      page  = (options[:page] || 1).to_i
      page = 1 if page < 1

      search = self.search do
        fulltext options[:query]
        with     :trusted, false unless options[:trusted]
        with     :conversation, (options[:conversation] || false)
        with     :discussion_id, options[:discussion_id] if options[:discussion_id]
        order_by :created_at, :desc
        paginate :page => page, :per_page => (options[:limit] || POSTS_PER_PAGE)
      end

      Pagination.apply(
        search.results,
        Pagination::Paginater.new(
          :total_count => search.total,
          :page        => page,
          :per_page    => (options[:limit] || POSTS_PER_PAGE)
        )
      )
    end
  end

  def me_post?
    @me_post ||= (body.strip =~ /^\/me/ && !(body =~ /\n/) ) ? true : false
  end

  # Get this posts sequence number
  def post_number
    @post_number ||= (Post.count(:conditions => ['discussion_id = ? AND id < ?', self.discussion_id, self.id]) + 1)
  end

  def page(options={})
    limit = options[:limit] || POSTS_PER_PAGE
    (post_number.to_f/limit).ceil
  end

  def body_html
    if self.new_record? || Rails.env == 'development'
      PostParser.new(self.body.dup).to_html
    else
      unless body_html?
        self.update_column(:body_html, PostParser.new(self.body.dup).to_html)
      end
      self[:body_html].html_safe
    end
  end

  def edited?
    return false unless edited_at?
    (((self.edited_at || self.created_at) - self.created_at) > 5.seconds ) ? true : false
  end

  def editable_by?(user)
    (user && (user.moderator? || user == self.user)) ? true : false
  end

  # Returns true if the user can view this post
  def viewable_by?(user)
    if self.trusted?
      (user && user.trusted?) ? true : false
    else
      (Sugar.public_browsing? || user) ? true : false
    end
  end

  def mentions_users?
    (mentioned_users.length > 0) ? true : false
  end

  def mentioned_users
    @mentioned_users ||= User.find(:all).select do |user|
      user_expression = Regexp.new('@'+Regexp.quote(user.username), Regexp::IGNORECASE)
      self.body.match(user_expression) ? true : false
    end
  end
end
