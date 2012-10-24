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

  self.table_name = 'discussions'

  # Default number of discussions per page
  DISCUSSIONS_PER_PAGE = 30

  # These attributes should be filtered from params
  UNSAFE_ATTRIBUTES = :id, :sticky, :user_id, :last_poster_id, :posts_count,
                      :created_at, :updated_at, :last_post_at, :trusted

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
  validates_length_of   :title, :maximum => 100
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

    # Deletes attributes which normal users shouldn't be able to touch from a param hash
    def safe_attributes(params)
      safe_params = params.dup
      Exchange::UNSAFE_ATTRIBUTES.each do |r|
        safe_params.delete(r)
      end
      return safe_params
    end

  end

  # Finds the number of the last page
  def last_page(per_page=Post::POSTS_PER_PAGE)
    (self.posts_count.to_f/per_page).ceil
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
    "#{self.id.to_s};" + slug
  end

  # Returns true if the user can close this discussion
  def closeable_by?(user)
    return false unless user
    (user.moderator? || (!self.closer && self.poster == user) || self.closer == user) ? true : false
  end

end
