# encoding: utf-8

class Post < ActiveRecord::Base
  include SearchablePost, Viewable

  POSTS_PER_PAGE  = 50

  belongs_to :user, :counter_cache => true
  belongs_to :discussion, :class_name => 'Exchange', :counter_cache => :posts_count, :foreign_key => 'discussion_id'
  has_many   :discussion_views

  validates_presence_of :body, :user_id, :discussion_id

  attr_accessor :skip_html

  before_save :set_edit_timestamp
  before_save :update_trusted_status
  before_save :flag_conversation
  before_save :render_html
  after_create :update_exchange
  after_create :define_relationship

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
      Sugar::PostRenderer.new(self.body.dup).to_html
    else
      unless body_html?
        self.update_column(:body_html, Sugar::PostRenderer.new(self.body.dup).to_html)
      end
      self[:body_html].html_safe
    end
  end

  def edited?
    return false unless edited_at?
    (((self.edited_at || self.created_at) - self.created_at) > 60.seconds ) ? true : false
  end

  def editable_by?(user)
    (user && (user.moderator? || user == self.user)) ? true : false
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

  private

  def update_trusted_status
    if self.discussion
      self.trusted = self.discussion.trusted
    end
    true
  end

  def render_html
    unless self.skip_html
      self.body_html = Sugar::PostRenderer.new(self.body).to_html
    end
  end

  def flag_conversation
    self.conversation = self.discussion.kind_of?(Conversation)
    true
  end

  def set_edit_timestamp
    self.edited_at ||= Time.now
  end

  # Make sure the discussion is marked as participated for the user
  def define_relationship
    unless self.conversation?
      DiscussionRelationship.define(self.user, self.discussion, :participated => true)
    end
  end

  # Automatically update the discussion with last poster info
  def update_exchange
    self.discussion.update_attributes(:last_poster_id => self.user.id, :last_post_at => self.created_at)
  end

end
